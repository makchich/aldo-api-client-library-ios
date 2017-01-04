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
    
    private enum Command: String {
        case REQUEST_AUTH_TOKEN = "/token"
    }
    
    public static func setHostAddress(address: String, port: Int = 4567) {
        HOST_ADDRESS = address
        PORT = port
    }
    
    public static func request(command: String, parameters: Parameters, callback: Callback) {
        let object = storage.object(forKey: authTokenStorageKey)
        let token: String = (object != nil) ? ":\(object as! String)" : ""
        
        let headers: HTTPHeaders = [
            "Authorization": "\(ID)\(token)"
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
        return storage.object(forKey: authTokenStorageKey) != nil
    }
    
    private class AuthTokenCallback: Callback {
        
        private var callback: Callback
        
        public init(callback: Callback) {
            self.callback = callback
        }
        
        public func onResponse(responseCode: Int, response: NSDictionary) {
            if(responseCode == 200) {
                storage.set(response["token"], forKey: authTokenStorageKey)
            }
            callback.onResponse(responseCode: responseCode, response: response)
        }
    }
}
