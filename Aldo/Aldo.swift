//
//  Aldo.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation
import Alamofire

public enum Command: String {
    case REQUEST_AUTH_TOKEN = "/token"
    case SESSION_CREATE = "/session/create"
    case SESSION_JOIN = "/session/join"
    case SESSION_LEAVE = "/session/leave"
}

protocol Callback {
    
    func onResponse(responseCode: Int, response: Any)
    
}

public class Aldo {
    
    private static var HOST_ADDRESS: String = "127.0.0.1"
    private static var PORT: Int = 4567
    
    private static var ID: String = UIDevice.current.identifierForVendor!.uuidString
    
    static func setHostAddress(address: String, port: Int = 4567) {
        HOST_ADDRESS = address
        PORT = port
    }
    
    static func request(command: String, parameters: Parameters, callback: Callback) {
        let headers: HTTPHeaders = [
            "Authorization": ID
        ]
        
        Alamofire.request("\(HOST_ADDRESS)\(command)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseString { response in
            let statusCode: Int = response.response!.statusCode
            let result: Any = response.result.value!
            callback.onResponse(responseCode: statusCode, response: result)
        }
    }
    
    static func request(command: Command, parameters: Parameters, callback: Callback) {
        request(command: command.rawValue, parameters: parameters, callback: callback)
    }
    
    static func requestAuthToken(callback: Callback) {
        let command: Command = Command.REQUEST_AUTH_TOKEN
        request(command: command, parameters: [:], callback: callback)
    }
    
}
