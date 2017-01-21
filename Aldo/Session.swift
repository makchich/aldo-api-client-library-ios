//
//  Session.swift
//  Pods
//
//  Created by Team Aldo on 04/01/2017.
//
//

import Foundation

/// Representation of a Session in the Aldo Framework.
public class Session: NSObject, NSCoding {

    /// Core states of a session.
    public enum Status: Int {

        /// The active status of a session.
        case PLAYING = 1

        /// The paused status of a session.
        case PAUSED = 0
    }

    private var id: String
    private var admin: String
    private var tokens: NSDictionary
    private var status: Status
    private var created: String

    /**
        Creates a *Player* containing all information that is passed.
     
        - Parameters:
            - id: The player id.
            - username: The username of the player.
            - session: An instance of *Session* containing all information the player is in.
            - role: The role of the player in the session.
            - score: The score of the player.
     */
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

    /// Returns the id of the session.
    public func getId() -> String {
        return self.id
    }

    /// Returns the player id of the administrator.
    public func getAdminId() -> String {
        return self.admin
    }

    /// Returns the join token for moderators if available.
    public func getModeratorToken() -> String {
        return self.tokens.count == 0 ? "" : self.tokens["moderator"] as! String
    }

    /// Returns the join token for regular players if available.
    public func getUserToken() -> String {
        return self.tokens.count == 0 ? "" : self.tokens["user"] as! String
    }

    /// Returns the status of the session.
    public func getStatus() -> Status {
        return self.status
    }

    /// Sets the status of the session.
    public func setStatus(status: Status) {
        self.status = status
    }

    /// Returns the creation date of the session.
    public func getCreationDate() -> String {
        return self.created
    }

}
