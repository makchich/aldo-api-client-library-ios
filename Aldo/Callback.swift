//
//  Callback.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation

/**
    Protocol for processing the reponse returned by the Aldo Framework.
 */
public protocol Callback {

    /**
        Processes the response returned by the Aldo Framework.
     
        - Parameters:
            - request: The request URI.
            - responseCode: The status code returned by the Aldo Framework.
            - response: The response returned by the Aldo Framework.
     */
    func onResponse(request: String, responseCode: Int, response: NSDictionary)

}

/**
    Realization of the Callback protocol to process the response
    of the core Aldo requests.
 */
class AldoMainCallback: Callback {

    /// A realization of the Callback protocol implemented
    /// by a developer using this library.
    private var callback: Callback?

    /**
        Initializer for the AldoMainCallback class.
        
        - Parameter callback: A realization of the Callback protocol to be called
                              when a response is returned from the Aldo Framework.
    */
    public init(callback: Callback? = nil) {
        self.callback = callback
    }

    // swiftlint:disable:next cyclomatic_complexity
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
                updatePlayerSession(response: response)
                break
            case Regex(pattern: RequestURI.SESSION_STATE_PLAY.regex()):
                updateSessionStatus(status: Session.Status.PLAYING)
                break
            case Regex(pattern: RequestURI.SESSION_STATE_PAUSE.regex()):
                updateSessionStatus(status: Session.Status.PAUSED)
                break
            case Regex(pattern: RequestURI.SESSION_DELETE.regex()):
                Aldo.getStorage().removeObject(forKey: Aldo.Keys.SESSION.rawValue)
                Aldo.getStorage().synchronize()
                break
            case Regex(pattern: RequestURI.PLAYER_USERNAME_UPDATE.regex()):
                savePlayer(response: response)
                break
            default:
                break
            }
        }

        if callback != nil {
            callback?.onResponse(request: request, responseCode: responseCode, response: response)
        }
    }
    // swiftlint:disable:previous cyclomatic_complexity

    /**
        Private helper method to convert the response returned by the Aldo Framework
        to a *Session* object.
     
        - Parameter response: The response returned by the Aldo Framework
     
        - Returns: an instance of *Session*
    */
    private func createSession(response: NSDictionary) -> Session {
        let sessionId = response["sessionID"] as! String
        let adminId = response["adminID"] as! String
        let tokens = (response["tokens"] != nil) ? response["tokens"] as! NSDictionary : [:]
        let status = response["status"] as! Int
        let created = response["created"] as! String

        return Session(id: sessionId, admin: adminId, tokens: tokens, status: status, created: created)
    }

    /**
     Private helper method to convert the response returned by the Aldo Framework
     to a *Player* object.
     
     - Parameter response: The response returned by the Aldo Framework
     
     - Returns: an instance of *Session*
     */
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

    /**
     Private helper method to update the session information on the device
     using the response returned by the Aldo Framework.
     
     - Parameter response: The response returned by the Aldo Framework.
     
     */
    private func updatePlayerSession(response: NSDictionary) {
        let player = Aldo.getPlayer()!
        let session = createSession(response: response)

        player.setSession(session: session)
        Aldo.setPlayer(player: player)
    }

    /**
     Private helper method to update the status of a session stored on the device
     using the new status returned by the Aldo Framework.
     
     - Parameter status: The new status returned by the Aldo Framework.
     
     */
    private func updateSessionStatus(status: Session.Status) {
        let player = Aldo.getPlayer()!
        player.getSession().setStatus(status: status)
        Aldo.setPlayer(player: player)
    }

}
