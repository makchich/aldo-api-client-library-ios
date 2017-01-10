//
//  Aldo.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation
import Alamofire

public enum AldoRequest: String {
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
        case .PLAYER_USERNAME_UPDATE:
            return String(format: self.rawValue, "(.)+?")
        default:
            return self.rawValue
        }
    }
}

open class Aldo {
    
    private static let storage = UserDefaults.standard
    enum Keys: String {
        case AUTH_TOKEN = "AUTH_TOKEN"
        case SESSION = "SESSION"
    }
    
    private static var HOST_ADDRESS: String = "127.0.0.1"
    private static var PORT: Int = 4567
    
    private static var ID: String = UIDevice.current.identifierForVendor!.uuidString
    
    open class func setHostAddress(address: String, port: Int = 4567) {
        HOST_ADDRESS = address
        PORT = port
    }
    
    open class func hasAuthToken() -> Bool {
        return storage.object(forKey: Keys.AUTH_TOKEN.rawValue) != nil
    }
    
    open class func hasSession() -> Bool {
        return storage.object(forKey: Keys.SESSION.rawValue) != nil
    }
    
    class func getStorage() -> UserDefaults {
        return storage
    }
    
    open class func getStoredSession() -> AldoSession? {
        if let objSession = storage.object(forKey: Keys.SESSION.rawValue) {
            let sessionData = objSession as! Data
            let session: AldoSession = NSKeyedUnarchiver.unarchiveObject(with: sessionData) as! AldoSession
            return session
        }
        return nil
    }
    
    open class func request(command: String, method: HTTPMethod, parameters: Parameters, callback: Callback? = nil) {
        let objToken = storage.object(forKey: Keys.AUTH_TOKEN.rawValue)
        let token: String = (objToken != nil) ? ":\(objToken as! String)" : ""
        
        
        var player: String = ""
        if let session = Aldo.getStoredSession() {
            player = ":\(session.getPlayerID())"
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "\(ID)\(token)\(player)"
        ]
        
        Alamofire.request("\(HOST_ADDRESS)\(command)", method: method, parameters: parameters, headers: headers).responseJSON { response in
            
            var result: NSDictionary = [:]
            if let JSON = response.result.value {
                result = JSON as! NSDictionary
            }
            let statusCode: Int = response.response!.statusCode
            
            AldoMainCallback(callback: callback).onResponse(request: command, responseCode: statusCode, response: result)
        }
    }
    
    open class func requestAuthToken(callback: Callback? = nil) {
        let command: String = AldoRequest.REQUEST_AUTH_TOKEN.rawValue
        request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    open class func createSession(username: String, callback: Callback? = nil) {
        let command: String = String(format: AldoRequest.SESSION_CREATE.rawValue, username)
        request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    open class func joinSession(username: String, token: String, callback: Callback? = nil) {
        let command: String = String(format: AldoRequest.SESSION_JOIN.rawValue, token, username)
        request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    open class func requestSessionInfo(callback: Callback? = nil) {
        let command: String = AldoRequest.SESSION_INFO.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    open class func requestSessionPlayers(callback: Callback? = nil) {
        let command: String = AldoRequest.SESSION_PLAYERS.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    open class func changeSessionState(newState: AldoSession.State, callback: Callback? = nil) {
        var command: String = AldoRequest.REQUEST_EMPTY.rawValue
        
        switch newState {
        case AldoSession.State.PLAY:
            command = AldoRequest.SESSION_STATE_PLAY.rawValue
            break
        case AldoSession.State.PAUSE:
            command = AldoRequest.SESSION_STATE_PAUSE.rawValue
            break
        }
        
        request(command: command, method: .put, parameters: [:], callback: callback)
    }
    
    open class func deleteSession(callback: Callback? = nil) {
        let command: String = AldoRequest.SESSION_DELETE.rawValue
        request(command: command, method: .delete, parameters: [:], callback: callback)
    }
    
    open class func requestDevicePlayers(callback: Callback? = nil) {
        let command: String = AldoRequest.PLAYER_ALL.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    open class func requestPlayerInfo(callback: Callback? = nil) {
        let command: String = AldoRequest.PLAYER_INFO.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    open class func updateUsername(username: String, callback: Callback? = nil) {
        let command: String = String(format: AldoRequest.PLAYER_USERNAME_UPDATE.rawValue, username)
        request(command: command, method: .put, parameters: [:], callback: callback)
    }
}
