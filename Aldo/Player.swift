//
//  Player.swift
//  Pods
//
//  Created by Team Aldo on 18/01/2017.
//
//

import Foundation



public class Player: NSObject, NSCoding {
    
    public enum Role: Int {
        case ADMIN = 0
        case MODERATOR = 1
        case USER = 2
    }
    
    private var id: String
    private var username: String
    private var session: Session
    private var role: Role
    private var score: Int
    
    public init(id: String, username: String, session: Session, role: Int, score: Int) {
        self.id = id
        self.username = username
        self.session = session
        self.role = Role(rawValue: role)!
        self.score = score
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let username = aDecoder.decodeObject(forKey: "username") as! String
        let session = aDecoder.decodeObject(forKey: "session") as! Session
        let role = (aDecoder.decodeObject(forKey: "role") as! NSNumber).intValue
        let score = (aDecoder.decodeObject(forKey: "score") as! NSNumber).intValue
        
        self.init(id: id, username: username, session: session, role: role, score: score)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.session, forKey: "session")
        aCoder.encode(NSNumber(value: self.role.rawValue), forKey: "role")
        aCoder.encode(NSNumber(value: self.score), forKey: "score")
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func getUsername() -> String {
        return self.username
    }
    
    public func setUsername(username: String) {
        self.username = username
    }
    
    public func getSession() -> Session {
        return self.session
    }
    
    public func setSession(session: Session) {
        self.session = session
    }
    
    public func getRole() -> Role {
        return self.role
    }
    
    public func isAdmin() -> Bool {
        return self.role == Role.ADMIN
    }
    
    public func isModerator() -> Bool {
        return self.role == Role.MODERATOR
    }
    
    public func isUser() -> Bool {
        return self.role == Role.USER
    }
    
    public func getScore() -> Int {
        return self.score
    }
}
