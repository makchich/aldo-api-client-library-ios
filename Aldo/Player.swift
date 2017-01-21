//
//  Player.swift
//  Pods
//
//  Created by Team Aldo on 18/01/2017.
//
//

import Foundation

/// Representation of the player in a session.
public class Player: NSObject, NSCoding {

    /**
        Core roles available in the Aldo Framework.
    */
    public enum Role: Int {

        /// Administrator of a session.
        case ADMIN = 0

        /// Moderator of a session.
        case MODERATOR = 1

        /// The regular player in a session.
        case USER = 2
    }

    private var id: String
    private var username: String
    private var session: Session
    private var role: Role
    private var score: Int

    /**
        Creates a *Player* containing all information that is passed.
     
        - Parameters:
            - id: The player id.
            - username: The username of the player.
            - session: An instance of *Session* containing all information the player is in.
            - role: The role of the player in the session.
            - score: The score of the player.
    */
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

    //// Returns the player id.
    public func getId() -> String {
        return self.id
    }

    /// Returns the username of the player.
    public func getUsername() -> String {
        return self.username
    }

    /** Returns an instance of *Session* containing information
        about the session the player is in.
    */
    public func getSession() -> Session {
        return self.session
    }

    /// Updates the information about the session the player is in.
    public func setSession(session: Session) {
        self.session = session
    }

    /// Returns the role of the player in the session.
    public func getRole() -> Role {
        return self.role
    }

    /// Checks whether the player is an administrator or not.
    public func isAdmin() -> Bool {
        return self.role == Role.ADMIN
    }

    /// Checks whether the player is a moderator or not.
    public func isModerator() -> Bool {
        return self.role == Role.MODERATOR
    }

    /// Checks whether the player is a regular player or not.
    public func isUser() -> Bool {
        return self.role == Role.USER
    }

    /// Returns the score of the player.
    public func getScore() -> Int {
        return self.score
    }
}
