//
//  Aldo.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation
import Alamofire

/**
    All core URI requests that are being processed by the Aldo Framework.
 */
public enum RequestURI: String {

    /// Dummy URI.
    case REQUEST_EMPTY = "/"

    /// URI to request and authorization token.
    case REQUEST_AUTH_TOKEN = "/token"

    /// URI template to create a session.
    case SESSION_CREATE = "/session/username/%@"

    /// URI template to join a session.
    case SESSION_JOIN = "/session/join/%@/username/%@"

    /// URI to get the information about the session.
    case SESSION_INFO = "/session"

    /// URI to get the players that have joined the session.
    case SESSION_PLAYERS = "/session/players"

    /// URI to resume the session.
    case SESSION_STATE_PLAY = "/session/play"

    /// URI to pause the session.
    case SESSION_STATE_PAUSE = "/session/pause"

    /// URI to stop and delete the session.
    case SESSION_DELETE = "/session/delete"

    /// URI to get all players linked to the device.
    case PLAYER_ALL = "/player/all"

    /// URI to get information of the active player.
    case PLAYER_INFO = "/player"

    /// URI template to update the username of the active player.
    case PLAYER_USERNAME_UPDATE = "/player/username/%@"

    /**
        Converts the rawValue to one containing regular expression for comparison.
     
        - Returns: A *String* representation as regular expression.
     */
    public func regex() -> String {
        var regex: String = "(.)+?"
        if self == .PLAYER_USERNAME_UPDATE {
            regex = "(.)+?$"
        }
        return "\(self.rawValue.replacingOccurrences(of: "%@", with: regex))$"
    }
}

/**
    Protocol for sending a request to the Aldo Framework.
 */
public protocol AldoRequester {

    /**
        Senda a request to the server running the Aldo Framework.
     
        - Parameters:
            - uri: The request to be send.
            - method: The HTTP method to be used for the request.
            - parameters: The information that should be passed in the body
            - callback: A realization of the Callback protocol to be called
                        when a response is returned from the Aldo Framework.
     */
    static func request(uri: String, method: HTTPMethod, parameters: Parameters, callback: Callback?)
}

/**
    Class containing static methods to communicate with the Aldo Framework.
 */
public class Aldo: AldoRequester {

    /// Keys for data storage
    public enum Keys: String {
        case AUTH_TOKEN
        case SESSION
    }

    static let storage = UserDefaults.standard

    static var hostAddress: String = "127.0.0.1"
    static let defaultPort: Int = 4567
    static var port: Int = 0

    static let id: String = UIDevice.current.identifierForVendor!.uuidString

    /**
        Define the address of the server running the Aldo Framework.
     
        - Parameters:
            - address: the address of the server running the Aldo Framework **without** a / at the end.
            - excludePort: wether or not to concatenate the port to the address.
    */
    public class func setHostAddress(address: String, excludePort: Bool = false) {
        Aldo.hostAddress = address
        Aldo.port = !excludePort ? defaultPort : 0
    }

    /**
        Define the address of the server running the Aldo Framework.
     
        - Parameters:
            - address: the address of the server running the Aldo Framework **without** a / at the end.
            - port: the port number the Aldo Framework is listening to.
     */
    public class func setHostAddress(address: String, port: Int) {
        Aldo.hostAddress = address
        Aldo.port = port
    }

    /**
        Checks whether the device already has an authorization token or not.
     
        - Returns: *true* if having a token, otherwise *false*.
    */
    public class func hasAuthToken() -> Bool {
        return storage.object(forKey: Keys.AUTH_TOKEN.rawValue) != nil
    }

    /**
        Checks wether the device has a information about a player in a session.
     
        - Returns: *true* if having information about a player, otherwise *false*.
    */
    public class func hasActivePlayer() -> Bool {
        return storage.object(forKey: Keys.SESSION.rawValue) != nil
    }

    /**
        Retrieves the storage where the information retrieved from the Aldo Framework is stored.
     
        - Returns: an instance of *UserDefaults*
     */
    public class func getStorage() -> UserDefaults {
        return storage
    }

    /**
        Retrieves the stored information about an active player.
     
        - Returns: an instance of *Player* if available, otherwise *nil*
     */
    public class func getPlayer() -> Player? {
        if let objSession = storage.object(forKey: Keys.SESSION.rawValue) {
            let sessionData = objSession as! Data
            let session: Player = NSKeyedUnarchiver.unarchiveObject(with: sessionData) as! Player
            return session
        }
        return nil
    }

    /// Stores information about an active player.
    public class func setPlayer(player: Player) {
        let playerData: Data = NSKeyedArchiver.archivedData(withRootObject: player)
        Aldo.getStorage().set(playerData, forKey: Aldo.Keys.SESSION.rawValue)
    }

    /**
        Private helper method to create the Authorization header for a request.
     */
    private class func createRequestHeaders() -> HTTPHeaders {
        let objToken = storage.object(forKey: Keys.AUTH_TOKEN.rawValue)
        let token: String = (objToken != nil) ? ":\(objToken as! String)" : ""

        var playerId: String = ""
        if let player = Aldo.getPlayer() {
            playerId = ":\(player.getId())"
        }

        return [
            "Authorization": "\(id)\(token)\(playerId)"
        ]
    }

    /**
        Senda a request to the server running the Aldo Framework.
     
        - Parameters:
            - uri: The request to be send.
            - method: The HTTP method to be used for the request.
            - parameters: The information that should be passed in the body
            - callback: A realization of the Callback protocol to be called
                        when a response is returned from the Aldo Framework.
     */
    open class func request(uri: String, method: HTTPMethod, parameters: Parameters, callback: Callback? = nil) {
        let headers = createRequestHeaders()
        let requestPort = (port <= 0) ? "" : ":\(port)"

        Alamofire.request("\(hostAddress)\(requestPort)\(uri)", method: method,
                          parameters: parameters, encoding: AldoEncoding(),
                          headers: headers).responseJSON { response in
            var result: NSDictionary = [:]
            if let JSON = response.result.value {
                result = JSON as! NSDictionary
            }

            var responseCode: Int = 499
            if let httpResponse = response.response {
                responseCode = httpResponse.statusCode
            }

            AldoMainCallback(callback: callback).onResponse(request: uri,
                                                            responseCode: responseCode, response: result)
        }
    }

    /**
        Sends a request to obtain an authorization token.
     
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
    */
    public class func requestAuthToken(callback: Callback? = nil) {
        let command: String = RequestURI.REQUEST_AUTH_TOKEN.rawValue
        request(uri: command, method: .post, parameters: [:], callback: callback)
    }

    /**
        Sends a request to create a session.
     
        - Parameters:
            - username: The username to be used.
            - callback: A realization of the Callback protocol to be called
                        when a response is returned from the Aldo Framework.
     */
    public class func createSession(username: String, callback: Callback? = nil) {
        let command: String = String(format: RequestURI.SESSION_CREATE.rawValue, username)
        request(uri: command, method: .post, parameters: [:], callback: callback)
    }

    /**
        Sends a request to join a session.
     
        - Parameters:
            - username: The username to be used.
            - token: The token to join a session.
            - callback: A realization of the Callback protocol to be called
                        when a response is returned from the Aldo Framework.
     */
    public class func joinSession(username: String, token: String, callback: Callback? = nil) {
        let command: String = String(format: RequestURI.SESSION_JOIN.rawValue, token, username)
        request(uri: command, method: .post, parameters: [:], callback: callback)
    }

    /**
        Sends a request to retrieve information about the session.
     
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
     */
    public class func requestSessionInfo(callback: Callback? = nil) {
        let command: String = RequestURI.SESSION_INFO.rawValue
        request(uri: command, method: .get, parameters: [:], callback: callback)
    }

    /**
        Sends a request to retrieve the players in the session.
     
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
     */
    public class func requestSessionPlayers(callback: Callback? = nil) {
        let command: String = RequestURI.SESSION_PLAYERS.rawValue
        request(uri: command, method: .get, parameters: [:], callback: callback)
    }

    /**
        Sends a request to change the status of the session.
     
        - Parameters:
            - newStatus: The new status of the session.
            - callback: A realization of the Callback protocol to be called
                        when a response is returned from the Aldo Framework.
     */
    public class func changeSessionStatus(newStatus: Session.Status, callback: Callback? = nil) {
        var command: String = RequestURI.SESSION_STATE_PLAY.rawValue

        if newStatus == Session.Status.PAUSED {
            command = RequestURI.SESSION_STATE_PAUSE.rawValue
        }

        request(uri: command, method: .put, parameters: [:], callback: callback)
    }

    /**
        Sends a request to delete the session.
     
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
     */
    public class func deleteSession(callback: Callback? = nil) {
        let command: String = RequestURI.SESSION_DELETE.rawValue
        request(uri: command, method: .delete, parameters: [:], callback: callback)
    }

    /**
        Sends a request to retrieve the players linked to the device.
     
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
     */
    public class func requestDevicePlayers(callback: Callback? = nil) {
        let command: String = RequestURI.PLAYER_ALL.rawValue
        request(uri: command, method: .get, parameters: [:], callback: callback)
    }

    /**
        Sends a request to retrieve information about the player.
     
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
     */
    public class func requestPlayerInfo(callback: Callback? = nil) {
        let command: String = RequestURI.PLAYER_INFO.rawValue
        request(uri: command, method: .get, parameters: [:], callback: callback)
    }

    /**
        Sends a request to change the username of the player.
     
        - Parameters:
            - username: The username to be used.
            - callback: A realization of the Callback protocol to be called
                        when a response is returned from the Aldo Framework.
     */
    public class func updateUsername(username: String, callback: Callback? = nil) {
        let command: String = String(format: RequestURI.PLAYER_USERNAME_UPDATE.rawValue, username)
        request(uri: command, method: .put, parameters: [:], callback: callback)
    }
}
