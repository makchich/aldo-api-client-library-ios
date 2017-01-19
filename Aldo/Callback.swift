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

class AldoMainCallback: Callback {
    
    private var callback: Callback?
    
    public init(callback: Callback? = nil) {
        self.callback = callback
    }
    
    public func onResponse(request: String, responseCode: Int, response: NSDictionary) {
        if responseCode == 200 {
            switch request {
            case Regex(pattern: RequestURI.REQUEST_AUTH_TOKEN.regex()):
                Aldo.getStorage().set(response["token"], forKey: Aldo.Keys.AUTH_TOKEN.rawValue)
                break
            case Regex(pattern: RequestURI.SESSION_CREATE.regex()):
                savePlayer(response: response)
                break
            case Regex(pattern: RequestURI.SESSION_JOIN.regex()):
                savePlayer(response: response)
                break
            case Regex(pattern: RequestURI.SESSION_INFO.regex()):
                let player = Aldo.getPlayer()!
                let session = createSession(response: response)
                
                player.setSession(session: session)
                Aldo.setPlayer(player: player)
                break
            case Regex(pattern: RequestURI.SESSION_PLAYERS.regex()):
                break
            case Regex(pattern: RequestURI.SESSION_STATE_PLAY.regex()):
                let player = Aldo.getPlayer()!
                player.getSession().setStatus(status: Session.Status.PLAYING)
                
                Aldo.setPlayer(player: player)
                break
            case Regex(pattern: RequestURI.SESSION_STATE_PAUSE.regex()):
                let player = Aldo.getPlayer()!
                player.getSession().setStatus(status: Session.Status.PAUSED)
                
                Aldo.setPlayer(player: player)
                break
            case Regex(pattern: RequestURI.SESSION_DELETE.regex()):
                Aldo.getStorage().removeObject(forKey: Aldo.Keys.SESSION.rawValue)
                Aldo.getStorage().synchronize()
                break
            case Regex(pattern: RequestURI.PLAYER_USERNAME_UPDATE.regex()):
                let player = Aldo.getPlayer()!
                player.setUsername(username: response["username"] as! String)
                break
            default:
                break
            }
        }
        
        if callback != nil {
            callback?.onResponse(request: request, responseCode: responseCode, response: response)
        }
    }
    
    private func createSession(response: NSDictionary) -> Session {
        let sessionId = response["sessionID"] as! String
        let adminId = response["adminID"] as! String
        let tokens = (response["tokens"] != nil) ? response["tokens"] as! NSDictionary : [:]
        let status = response["status"] as! Int
        let created = response["created"] as! String
        
        return Session(id: sessionId, admin: adminId, tokens: tokens, status: status, created: created)
    }
    
    private func savePlayer(response: NSDictionary) {
        let id = response["playerID"] as! String
        let username = response["username"] as! String
        let sessionDictionary = response["session"] as! NSDictionary
        let role = response["role"] as! Int
        let score = response["score"] as! Int
        
        let session: Session = createSession(response: sessionDictionary)
        let player: Player = Player(id: id, username: username, session: session, role: role, score: score)
        
        Aldo.setPlayer(player: player)
    }
    
}
