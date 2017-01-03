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
    
}
