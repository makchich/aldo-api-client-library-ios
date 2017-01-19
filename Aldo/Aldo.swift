//
//  Aldo.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation
import Alamofire

public enum RequestURI: String {
    case REQUEST_EMPTY = "/"
    case REQUEST_AUTH_TOKEN = "/token"
    
    case SESSION_CREATE = "/session/username/%@"
    case SESSION_JOIN = "/session/join/%@/username/%@"
    case SESSION_INFO = "/session"
    case SESSION_PLAYERS = "/session/players"
    case SESSION_STATE_PLAY = "/session/play"
    case SESSION_STATE_PAUSE = "/session/pause"
    case SESSION_DELETE = "/session/delete"
    
    case PLAYER_ALL = "/player/all"
    case PLAYER_INFO = "/player"
    case PLAYER_USERNAME_UPDATE = "/player/username/%@"
    
    public func regex() -> String {
        switch self {
        case .SESSION_CREATE:
            return String(format: self.rawValue, "(.)+?")
        case .SESSION_JOIN:
            return String(format: self.rawValue, "(.)+?", "(.)+?")
        case .SESSION_INFO:
            return "\(self.rawValue)$"
        case .PLAYER_USERNAME_UPDATE:
            return String(format: self.rawValue, "(.)+?$")
        default:
            return self.rawValue
        }
    }
}

public protocol AldoRequester {
    static func request(command: String, method: HTTPMethod, parameters: Parameters, callback: Callback?)
}

public class Aldo: AldoRequester {
    
    public enum Keys: String {
        case AUTH_TOKEN = "AUTH_TOKEN"
        case SESSION = "SESSION"
    }
    
    static let storage = UserDefaults.standard
    
    static var hostAddress: String = "127.0.0.1"
    static let defaultPort: Int = 4567
    static var port: Int = 0
    
    static let ID: String = UIDevice.current.identifierForVendor!.uuidString
    
    public class func setHostAddress(address: String, excludePort: Bool = false) {
        Aldo.hostAddress = address
        Aldo.port = !excludePort ? defaultPort : 0
    }
    
    public class func setHostAddress(address: String, port: Int) {
        Aldo.hostAddress = address
        Aldo.port = port
    }
    
    public class func hasAuthToken() -> Bool {
        return storage.object(forKey: Keys.AUTH_TOKEN.rawValue) != nil
    }
    
    public class func hasActivePlayer() -> Bool {
        return storage.object(forKey: Keys.SESSION.rawValue) != nil
    }
    
    public class func getStorage() -> UserDefaults {
        return storage
    }
    
    public class func getPlayer() -> Player? {
        if let objSession = storage.object(forKey: Keys.SESSION.rawValue) {
            let sessionData = objSession as! Data
            let session: Player = NSKeyedUnarchiver.unarchiveObject(with: sessionData) as! Player
            return session
        }
        return nil
    }
    
    public class func setPlayer(player: Player) {
        let playerData: Data = NSKeyedArchiver.archivedData(withRootObject: player)
        Aldo.getStorage().set(playerData, forKey: Aldo.Keys.SESSION.rawValue)
    }
    
    private class func createRequestHeaders() -> HTTPHeaders {
        let objToken = storage.object(forKey: Keys.AUTH_TOKEN.rawValue)
        let token: String = (objToken != nil) ? ":\(objToken as! String)" : ""
        
        var playerId: String = ""
        if let player = Aldo.getPlayer() {
            playerId = ":\(player.getId())"
        }
        
        return [
            "Authorization": "\(ID)\(token)\(playerId)"
        ]
    }
    
    open class func request(command: String, method: HTTPMethod, parameters: Parameters, callback: Callback? = nil) {
        let headers = createRequestHeaders()
        let requestPort = (port <= 0) ? "" : ":\(port)"
        
        Alamofire.request("\(hostAddress)\(requestPort)\(command)", method: method, parameters: parameters, encoding: AldoEncoding(), headers: headers).responseJSON { response in
            var result: NSDictionary = [:]
            if let JSON = response.result.value {
                result = JSON as! NSDictionary
            }
            
            var responseCode: Int = 499
            if let httpResponse = response.response {
                responseCode = httpResponse.statusCode
            }
            
            AldoMainCallback(callback: callback).onResponse(request: command, responseCode: responseCode, response: result)
        }
    }
    
    public class func requestAuthToken(callback: Callback? = nil) {
        let command: String = RequestURI.REQUEST_AUTH_TOKEN.rawValue
        request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    public class func createSession(username: String, callback: Callback? = nil) {
        let command: String = String(format: RequestURI.SESSION_CREATE.rawValue, username)
        request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    public class func joinSession(username: String, token: String, callback: Callback? = nil) {
        let command: String = String(format: RequestURI.SESSION_JOIN.rawValue, token, username)
        request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    public class func requestSessionInfo(callback: Callback? = nil) {
        let command: String = RequestURI.SESSION_INFO.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    public class func requestSessionPlayers(callback: Callback? = nil) {
        let command: String = RequestURI.SESSION_PLAYERS.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    public class func changeSessionStatus(newStatus: Session.Status, callback: Callback? = nil) {
        var command: String = RequestURI.REQUEST_EMPTY.rawValue
        
        switch newStatus {
        case Session.Status.PLAYING:
            command = RequestURI.SESSION_STATE_PLAY.rawValue
            break
        case Session.Status.PAUSED:
            command = RequestURI.SESSION_STATE_PAUSE.rawValue
            break
        }
        
        request(command: command, method: .put, parameters: [:], callback: callback)
    }
    
    public class func deleteSession(callback: Callback? = nil) {
        let command: String = RequestURI.SESSION_DELETE.rawValue
        request(command: command, method: .delete, parameters: [:], callback: callback)
    }
    
    public class func requestDevicePlayers(callback: Callback? = nil) {
        let command: String = RequestURI.PLAYER_ALL.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    public class func requestPlayerInfo(callback: Callback? = nil) {
        let command: String = RequestURI.PLAYER_INFO.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    public class func updateUsername(username: String, callback: Callback? = nil) {
        let command: String = String(format: RequestURI.PLAYER_USERNAME_UPDATE.rawValue, username)
        request(command: command, method: .put, parameters: [:], callback: callback)
    }
}
