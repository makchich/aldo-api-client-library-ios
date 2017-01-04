//
//  Aldo.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation
import Alamofire

public class Aldo {
    
    private static let storage = UserDefaults.standard
    private static let authTokenStorageKey = "AUTH_TOKEN"
    
    private static var HOST_ADDRESS: String = "127.0.0.1"
    private static var PORT: Int = 4567
    
    private static var ID: String = UIDevice.current.identifierForVendor!.uuidString
    
    private enum Keys: String {
        case AUTH_TOKEN = "AUTH_TOKEN"
        case SESSION_ID = "SESSION_ID"
        case SESSION_PLAYER_ID = "SESSION_PLAYER_ID"
        case SESSION_USERNAME = "SESSION_USERNAME"
        case SESSION_MOD_TOKEN = "SESSION_MOD_TOKEN"
        case SESSION_PLAY_TOKEN = "SESSION_PLAY_TOKEN"
    }
    
    private enum Command: String {
        case REQUEST_AUTH_TOKEN = "/token"
        case CREATE_SESSION = "/session/username/"
    }
    
    public static func setHostAddress(address: String, port: Int = 4567) {
        HOST_ADDRESS = address
        PORT = port
    }
    
    public static func request(command: String, parameters: Parameters, callback: Callback) {
        let objToken = storage.object(forKey: Keys.AUTH_TOKEN.rawValue)
        let token: String = (objToken != nil) ? ":\(objToken as! String)" : ""
        
        
        let objPlayer = storage.object(forKey: Keys.SESSION_PLAYER_ID.rawValue)
        let player: String = (objPlayer != nil) ? ":\(objPlayer as! String)" : ""
        
        let headers: HTTPHeaders = [
            "Authorization": "\(ID)\(token)\(player)"
        ]
        
        Alamofire.request("\(HOST_ADDRESS)\(command)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            var result: NSDictionary = [:]
            if let JSON = response.result.value {
                result = JSON as! NSDictionary
            }
            let statusCode: Int = response.response!.statusCode
            callback.onResponse(responseCode: statusCode, response: result)
        }
    }
    
    public static func requestAuthToken(callback: Callback) {
        let command: Command = Command.REQUEST_AUTH_TOKEN
        let authTokenCallback: Callback = AuthTokenCallback(callback: callback)
        
        request(command: command.rawValue, parameters: [:], callback: authTokenCallback)
    }
    
    public static func hasAuthToken() -> Bool {
        return storage.object(forKey: Keys.AUTH_TOKEN.rawValue) != nil
    }
    
    public static func createSession(username: String, callback: Callback) {
        let command: String = "\(Command.CREATE_SESSION.rawValue)\(username)"
        let createSessionCallback: Callback = CreateSessionCallback(username: username, callback: callback)
    }
    
    public static func hasSession() -> Bool {
        return storage.object(forKey: Keys.SESSION_ID.rawValue) != nil
    }
    
    public static func isSessionAdmin() -> Bool {
        let hasModtoken: Bool = storage.object(forKey: Keys.SESSION_MOD_TOKEN.rawValue) != nil
        let hasPlayToken: Bool = storage.object(forKey: Keys.SESSION_PLAY_TOKEN.rawValue) != nil
        return hasSession() && hasModtoken && hasPlayToken
    }
    
    private class AuthTokenCallback: Callback {
        
        private var callback: Callback
        
        public init(callback: Callback) {
            self.callback = callback
        }
        
        public func onResponse(responseCode: Int, response: NSDictionary) {
            if(responseCode == 200) {
                storage.set(response["token"], forKey: Keys.AUTH_TOKEN.rawValue)
            }
            callback.onResponse(responseCode: responseCode, response: response)
        }
    }
    
    private class CreateSessionCallback: Callback {
        
        private var username: String
        private var callback: Callback
        
        public init(username: String, callback: Callback) {
            self.username = username
            self.callback = callback
        }
        
        public func onResponse(responseCode: Int, response: NSDictionary) {
            if(responseCode == 200) {
                storage.set(username, forKey: Keys.SESSION_USERNAME.rawValue)
                storage.set(response["sessionID"], forKey: Keys.SESSION_ID.rawValue)
                storage.set(response["playerID"], forKey: Keys.SESSION_PLAYER_ID.rawValue)
                storage.set(response["modToken"], forKey: Keys.SESSION_MOD_TOKEN.rawValue)
                storage.set(response["userToken"], forKey: Keys.SESSION_PLAY_TOKEN.rawValue)
            }
            callback.onResponse(responseCode: responseCode, response: response)
        }
        
    }
}
