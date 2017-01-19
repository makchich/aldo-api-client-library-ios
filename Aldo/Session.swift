//
//  Session.swift
//  Pods
//
//  Created by Team Aldo on 04/01/2017.
//
//

import Foundation

public class Session: NSObject, NSCoding {
    
    public enum Status: Int {
        case PLAYING = 1
        case PAUSED = 0
    }
    
    private var id: String
    private var admin: String
    private var tokens: NSDictionary
    private var status: Status
    private var created: String
    
    public init(id: String, admin: String, tokens: NSDictionary = [:], status: Int, created: String) {
        self.id = id
        self.admin = admin
        self.tokens = tokens
        self.created = created
        self.status = Status(rawValue: status)!
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let admin = aDecoder.decodeObject(forKey: "admin") as! String
        let tokens = aDecoder.decodeObject(forKey: "tokens") as! NSDictionary
        let status = (aDecoder.decodeObject(forKey: "status") as! NSNumber).intValue
        let created = aDecoder.decodeObject(forKey: "created") as! String
        
        self.init(id: id, admin: admin, tokens: tokens, status: status, created: created)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.admin, forKey: "admin")
        aCoder.encode(self.tokens, forKey: "tokens")
        aCoder.encode(NSNumber(value: self.status.rawValue), forKey: "status")
        aCoder.encode(self.created, forKey: "created")
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func getAdminId() -> String {
        return self.admin
    }
    
    public func getModeratorToken() -> String {
        return self.tokens.count == 0 ? "" : self.tokens["moderator"] as! String
    }
    
    public func getUserToken() -> String {
        return self.tokens.count == 0 ? "" : self.tokens["user"] as! String
    }
    
    public func getStatus() -> Status {
        return self.status
    }
    
    public func setStatus(status: Status) {
        self.status = status
    }
    
    public func getCreationDate() -> String {
        return self.created
    }
    
}
