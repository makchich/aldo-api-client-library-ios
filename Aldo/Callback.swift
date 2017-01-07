//
//  Callback.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation

public protocol Callback {
    
    func onResponse(request: String, responseCode: Int, response: NSDictionary)
    
}

public class AldoMainCallback: Callback {
    
    private var callback: Callback
    
    public init(callback: Callback? = nil) {
        self.callback = callback!
    }
    
    public func onResponse(request: String, responseCode: Int, response: NSDictionary) {
        if responseCode == 200 {
            switch request {
            case AldoRequest.REQUEST_AUTH_TOKEN.rawValue:
                Aldo.getStorage().set(response["token"], forKey: Aldo.Keys.AUTH_TOKEN.rawValue)
                break
            case AldoRequest.SESSION_CREATE.rawValue:
                let data: [String: String] = [
                    "sessionID": response["sessionID"] as! String,
                    "playerID": response["playerID"] as! String,
                    "modToken": response["modToken"] as! String,
                    "userToken": response["userToken"] as! String,
                    "username": response["username"] as! String
                ]
                let session: AldoSession = AldoSession(data: data)
                let sessionData: Data = NSKeyedArchiver.archivedData(withRootObject: session)
                Aldo.getStorage().set(sessionData, forKey: Aldo.Keys.SESSION.rawValue)
                break
            case AldoRequest.SESSION_JOIN.rawValue:
                let data: [String: String] = [
                    "sessionID": response["sessionID"] as! String,
                    "playerID": response["playerID"] as! String,
                    "modToken": "",
                    "userToken": "",
                    "username": response["username"] as! String
                ]
                let session: AldoSession = AldoSession(data: data)
                let sessionData: Data = NSKeyedArchiver.archivedData(withRootObject: session)
                Aldo.getStorage().set(sessionData, forKey: Aldo.Keys.SESSION.rawValue)
                break
            case AldoRequest.SESSION_INFO.rawValue:
                break
            case AldoRequest.SESSION_PLAYERS.rawValue:
                
                break
            case AldoRequest.SESSION_STATE_PLAY.rawValue:
                break
            case AldoRequest.SESSION_STATE_PAUSE.rawValue:
                break
            case AldoRequest.SESSION_DELETE.rawValue:
                Aldo.getStorage().removeObject(forKey: Aldo.Keys.SESSION.rawValue)
                break
            case AldoRequest.PLAYER_ALL.rawValue:
                break
            case AldoRequest.PLAYER_INFO.rawValue:
                break
            case AldoRequest.PLAYER_USERNAME_UPDATE.rawValue:
                break
            default:
                break
            }
        }
        
        if callback != nil {
            callback.onResponse(request: request, responseCode: responseCode, response: response)
        }
    }
    
}
