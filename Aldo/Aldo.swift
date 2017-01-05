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
        case SESSION = "SESSION"
    }
    
    private enum Command: String {
        case REQUEST_AUTH_TOKEN = "/token"
        case CREATE_SESSION = "/session/username/"
        case JOIN_SESSION = "/session/join/%s/username/%s"
    }
    
    public static func setHostAddress(address: String, port: Int = 4567) {
        HOST_ADDRESS = address
        PORT = port
    }
    
    public static func request(command: String, parameters: Parameters, callback: Callback) {
        let objToken = storage.object(forKey: Keys.AUTH_TOKEN.rawValue)
        let token: String = (objToken != nil) ? ":\(objToken as! String)" : ""
        
        
        var player: String = ""
        if let session = Aldo.getSession() {
            player = ":\(session.getPlayerID())"
        }
        
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
        
        request(command: command, parameters: [:], callback: createSessionCallback)
    }
    
    public static func joinSession(username: String, token: String, callback: Callback) {
        let command: String = String(format: Command.JOIN_SESSION.rawValue, token, username)
        let joinSessionCallback: Callback = JoinSessionCallback(username: username, callback: callback)
        
        request(command: command, parameters: [:], callback: joinSessionCallback)
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
                let data: [String: String] = [
                    "sessionID": response["sessionID"] as! String,
                    "playerID": response["playerID"] as! String,
                    "modToken": response["modToken"] as! String,
                    "userToken": response["userToken"] as! String,
                    "username": username
                ]
                let session: AldoSession = AldoSession(data: data)
                let sessionData: Data = NSKeyedArchiver.archivedData(withRootObject: session)
                storage.set(sessionData, forKey: Keys.SESSION.rawValue)
            }
            callback.onResponse(responseCode: responseCode, response: response)
        }
    }
    
    private class JoinSessionCallback: Callback {
        
        private var username: String
        private var callback: Callback
        
        public init(username: String, callback: Callback) {
            self.username = username
            self.callback = callback
        }
        
        public func onResponse(responseCode: Int, response: NSDictionary) {
            if(responseCode == 200) {
                let data: [String: String] = [
                    "sessionID": response["sessionID"] as! String,
                    "playerID": response["playerID"] as! String,
                    "modToken": "",
                    "userToken": "",
                    "username": username as! String
                ]
                let session: AldoSession = AldoSession(data: data)
                let sessionData: Data = NSKeyedArchiver.archivedData(withRootObject: session)
                storage.set(sessionData, forKey: Keys.SESSION.rawValue)
            }
            callback.onResponse(responseCode: responseCode, response: response)
        }
        
    }
}
