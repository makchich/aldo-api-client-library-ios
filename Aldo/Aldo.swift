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
    case REQUEST_AUTH_TOKEN = "/token"
    case SESSION_CREATE = "/session/username/"
    case SESSION_JOIN = "/session/join/%@/username/%@"
    case SESSION_DELETE = "/session/delete"
    case SESSION_PLAYERS = "/session/players"
}

public class Aldo {
    
    private static let storage = UserDefaults.standard
    enum Keys: String {
        case AUTH_TOKEN = "AUTH_TOKEN"
        case SESSION = "SESSION"
    }
    
    private static var HOST_ADDRESS: String = "127.0.0.1"
    private static var PORT: Int = 4567
    
    private static var ID: String = UIDevice.current.identifierForVendor!.uuidString
    
    public static func setHostAddress(address: String, port: Int = 4567) {
        HOST_ADDRESS = address
        PORT = port
    }
    
    static func getStorage() -> UserDefaults {
        return storage
    }
    
    public static func request(command: String, method: HTTPMethod, parameters: Parameters, callback: Callback) {
        let objToken = storage.object(forKey: Keys.AUTH_TOKEN.rawValue)
        let token: String = (objToken != nil) ? ":\(objToken as! String)" : ""
        
        
        var player: String = ""
        if let session = Aldo.getSession() {
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
            callback.onResponse(request: command, responseCode: statusCode, response: result)
        }
    }
    
    public static func requestAuthToken(callback: Callback) {
        let command: String = AldoRequest.REQUEST_AUTH_TOKEN.rawValue
        let mainCallback: Callback = AldoMainCallback(callback: callback)
        
        request(command: command, method: .post, parameters: [:], callback: mainCallback)
    }
    
    public static func hasAuthToken() -> Bool {
        return storage.object(forKey: Keys.AUTH_TOKEN.rawValue) != nil
    }
    
    public static func createSession(username: String, callback: Callback) {
        let command: String = "\(AldoRequest.SESSION_CREATE.rawValue)\(username)"
        let mainCallback: Callback = AldoMainCallback(callback: callback)
        
        request(command: command, method: .post, parameters: [:], callback: mainCallback)
    }
    
    public static func joinSession(username: String, token: String, callback: Callback) {
        let command: String = String(format: AldoRequest.SESSION_JOIN.rawValue, token, username)
        let mainCallback: Callback = AldoMainCallback(callback: callback)
        
        request(command: command, method: .post, parameters: [:], callback: mainCallback)
    }
    
    public static func deleteSession(callback: Callback) {
        let command: String = AldoRequest.SESSION_DELETE.rawValue
        let mainCallback: Callback = AldoMainCallback(callback: callback)
        
        request(command: command, method: .delete, parameters: [:], callback: mainCallback)
    }
    
    public static func getSessionPlayers(callback: Callback) {
        let command: String = AldoRequest.SESSION_PLAYERS.rawValue
        request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    public static func hasSession() -> Bool {
        return storage.object(forKey: Keys.SESSION.rawValue) != nil
    }
    
    public static func getSession() -> AldoSession? {
        if let objSession = storage.object(forKey: Keys.SESSION.rawValue) {
            let sessionData = objSession as! Data
            let session: AldoSession = NSKeyedUnarchiver.unarchiveObject(with: sessionData) as! AldoSession
            return session
        }
        return nil
    }
}
