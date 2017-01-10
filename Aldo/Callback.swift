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
    
    private var callback: Callback?
    
    public init(callback: Callback? = nil) {
        self.callback = callback
    }
    
    public func onResponse(request: String, responseCode: Int, response: NSDictionary) {
        if responseCode == 200 {
            switch request {
            case Regex(pattern: AldoRequest.REQUEST_AUTH_TOKEN.regex()):
                Aldo.getStorage().set(response["token"], forKey: Aldo.Keys.AUTH_TOKEN.rawValue)
                break
            case Regex(pattern: AldoRequest.SESSION_CREATE.regex()):
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
            case Regex(pattern: AldoRequest.SESSION_JOIN.regex()):
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
            case Regex(pattern: AldoRequest.SESSION_INFO.regex()):
                break
            case Regex(pattern: AldoRequest.SESSION_PLAYERS.regex()):
                
                break
            case Regex(pattern: AldoRequest.SESSION_STATE_PLAY.regex()):
                break
            case Regex(pattern: AldoRequest.SESSION_STATE_PAUSE.regex()):
                break
            case Regex(pattern: AldoRequest.SESSION_DELETE.regex()):
                Aldo.getStorage().removeObject(forKey: Aldo.Keys.SESSION.rawValue)
                break
            case Regex(pattern: AldoRequest.PLAYER_ALL.regex()):
                break
            case Regex(pattern: AldoRequest.PLAYER_INFO.regex()):
                break
            case Regex(pattern: AldoRequest.PLAYER_USERNAME_UPDATE.regex()):
                break
            default:
                break
            }
        }
        
        if callback != nil {
            callback?.onResponse(request: request, responseCode: responseCode, response: response)
        }
    }
    
}
