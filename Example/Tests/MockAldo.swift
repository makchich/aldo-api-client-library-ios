import Foundation
import Alamofire
@testable import Aldo

public class MockAldo: Aldo {
    
    public class func getHostAddress() -> String {
        return Aldo.hostAddress
    }
    
    public class func getPort() -> Int {
        return Aldo.port
    }
    
    override public class func request(uri: String, method: HTTPMethod, parameters: Parameters, callback: Callback? = nil) {
        var response: Dictionary<String, Any> = [:]
        var components = uri.components(separatedBy: "/")
        
        switch uri {
        case Regex(pattern: RequestURI.REQUEST_AUTH_TOKEN.regex()):
            response["deviceID"] = AldoTests.deviceId
            response["token"] = AldoTests.authToken
            break
        case Regex(pattern: RequestURI.SESSION_CREATE.regex()):
            response = createPlayerResponse(role: Player.Role.ADMIN)
            response["username"] = components[3]
            break
        case Regex(pattern: RequestURI.SESSION_JOIN.regex()):
            let isUserJoin = (components[3] == AldoTests.userToken)
            
            response = createPlayerResponse()
            response["role"] = isUserJoin ? Player.Role.USER.rawValue : Player.Role.MODERATOR.rawValue
            response["username"] = components[5]
            break
        case Regex(pattern: RequestURI.SESSION_INFO.regex()):
            let player: Player = MockAldo.getPlayer()!
            response = createSessionResponse(role: player.getRole())
            break
        case Regex(pattern: RequestURI.SESSION_PLAYERS.regex()):
            var players = [Dictionary<String, Any>]()
            var player: Dictionary<String, Any> = [:]
            player["playerID"] = AldoTests.playerId
            player["username"] = AldoTests.username
            player["score"] = 0
            
            players.append(player)
            response["players"] = players
            break
        case Regex(pattern: RequestURI.SESSION_STATE_PLAY.regex()):
            response = createSessionResponse()
            break
        case Regex(pattern: RequestURI.SESSION_STATE_PAUSE.regex()):
            response = createSessionResponse()
            response["status"] = Session.Status.PAUSED.rawValue
            break
        case Regex(pattern: RequestURI.SESSION_DELETE.regex()):
            response = createSessionResponse()
            response["status"] = 0
            break
        case Regex(pattern: RequestURI.PLAYER_ALL.regex()):
            var players = [Dictionary<String, Any>]()
            
            players.append(createPlayerResponse())
            response["players"] = players
            break
        case Regex(pattern: RequestURI.PLAYER_INFO.regex()):
            response = createPlayerResponse()
            break
        case Regex(pattern: RequestURI.PLAYER_USERNAME_UPDATE.regex()):
            response = createPlayerResponse()
            response["username"] = components[3]
            break
        default:
            break
        }
        AldoMainCallback(callback: callback).onResponse(request: uri, responseCode: 200, response: response as NSDictionary)
    }
    
    
    /// Helper method to simulate the way the Aldo Framework
    /// returns information about a session.
    public static func createSessionResponse(role: Player.Role = Player.Role.USER) -> Dictionary<String, Any> {
        var response: Dictionary<String, Any> = [:]
        response["sessionID"] = AldoTests.sessionId
        response["adminID"] = AldoTests.playerId
        response["status"] = Session.Status.PLAYING.rawValue
        response["created"] = AldoTests.creationDate
        
        if role == Player.Role.ADMIN {
            response["tokens"] = createTokensResponse()
        }
        return response
    }
    
    /// Helper method to simulate the way the Aldo Framework
    /// returns information about the join tokens of a session.
    public static func createTokensResponse() -> Dictionary<String, Any> {
        var response: Dictionary<String, String> = [:]
        response["moderator"] = AldoTests.moderatorToken
        response["user"] = AldoTests.userToken
        return response
    }
    
    /// Helper method to simulate the way the Aldo Framework
    /// returns information about a player.
    public static func createPlayerResponse(role: Player.Role = Player.Role.USER) -> Dictionary<String, Any> {
        var response: Dictionary<String, Any> = [:]
        response["playerID"] = AldoTests.playerId
        response["session"] = createSessionResponse(role: role)
        response["role"] = role.rawValue
        response["score"] = 0
        response["username"] = AldoTests.username
        return response
    }
    
}
