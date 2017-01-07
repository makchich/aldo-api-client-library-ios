//
//  Session.swift
//  Pods
//
//  Created by Team Aldo on 04/01/2017.
//
//

import Foundation

public class AldoSession: NSObject, NSCoding {
    
    public enum State: Int {
        case PLAY = 1
        case PAUSE = 0
    }
    
    private var sessionId: String
    private var playerId: String
    private var modToken: String
    private var userToken: String
    private var username: String
    
    public init(data: [String: String]) {
        self.sessionId = data["sessionID"]!
        self.playerId = data["playerID"]!
        self.modToken = data["modToken"]!
        self.userToken = data["userToken"]!
        self.username = data["username"]!
    }
    
    public init(sessionId: String, playerId: String, modToken: String, userToken: String, username: String) {
        self.sessionId = sessionId
        self.playerId = playerId
        self.modToken = modToken
        self.userToken = userToken
        self.username = username
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        let sessionId = aDecoder.decodeObject(forKey: "sessionID") as! String
        let playerId = aDecoder.decodeObject(forKey: "playerID") as! String
        let modToken = aDecoder.decodeObject(forKey: "modToken") as! String
        let userToken = aDecoder.decodeObject(forKey: "userToken") as! String
        let username = aDecoder.decodeObject(forKey: "username") as! String
        self.init(sessionId: sessionId, playerId: playerId, modToken: modToken, userToken: userToken, username: username)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(sessionId, forKey: "sessionID")
        aCoder.encode(playerId, forKey: "playerID")
        aCoder.encode(modToken, forKey: "modToken")
        aCoder.encode(userToken, forKey: "userToken")
        aCoder.encode(username, forKey: "username")
    }
    
    public func isAdmin() -> Bool {
        return getModToken() != "" && getUserToken() != ""
    }
    
    public func getSessionID() -> String {
        return self.sessionId
    }
    
    public func getPlayerID() -> String {
        return self.playerId
    }
    
    public func getModToken() -> String {
        return self.modToken
    }
    
    public func getUserToken() -> String {
        return self.userToken
    }
    
    public func getUsername() -> String {
        return self.username
    }
    
    public func setUsername(username: String) {
        self.username = username
    }
    
}
