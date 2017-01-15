import Foundation
import Alamofire
@testable import Aldo

public class MockAldo: Aldo {
    
    private static var mockAddress: String = ""
    private static var mockPort: Int  = -1
    
    public class func getHostAddress() -> String {
        return MockAldo.mockAddress
    }
    
    public class func getPort() -> Int {
        return MockAldo.mockPort
    }
    
    override public class func setHostAddress(address: String, port: Int = 4567) {
        super.setHostAddress(address: address, port: port)
        
        mockAddress = address
        mockPort = port
    }
    
    override open class func request(command: String, method: HTTPMethod, parameters: Parameters, callback: Callback? = nil) {
        var response: Dictionary<String, String> = [:]
        var components = command.components(separatedBy: "/")
        
        switch command {
        case Regex(pattern: AldoRequest.REQUEST_AUTH_TOKEN.regex()):
            response["deviceID"] = UIDevice.current.identifierForVendor!.uuidString
            response["token"] = "1111-2222-3333-4444-5555"
            break
        case Regex(pattern: AldoRequest.SESSION_CREATE.regex()):
            response["sessionID"] = "0000-2222-4444-6666-8888"
            response["playerID"] = "1111-3333-5555-7777-9999"
            response["modToken"] = "acegik"
            response["userToken"] = "bdfhj"
            response["username"] = components[3]
            break
        case Regex(pattern: AldoRequest.SESSION_JOIN.regex()):
            response["sessionID"] = "0000-2222-4444-6666-8888"
            response["playerID"] = "1111-3333-5555-7777-9999"
            response["username"] = components[5]
            break
        case Regex(pattern: AldoRequest.SESSION_INFO.regex()):
            response["sessionID"] = "0000-2222-4444-6666-8888"
            response["adminID"] = "1111-3333-5555-7777-9999"
            response["status"] = "1"
            response["created"] = "01-01-1970"
            break
        default:
            break
        }
        AldoMainCallback(callback: callback).onResponse(request: command, responseCode: 200, response: response as NSDictionary)
    }
    
    override public class func requestAuthToken(callback: Callback? = nil) {
        let command: String = AldoRequest.REQUEST_AUTH_TOKEN.rawValue
        MockAldo.request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    override public class func createSession(username: String, callback: Callback? = nil) {
        let command: String = String(format: AldoRequest.SESSION_CREATE.rawValue, username)
        MockAldo.request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    override public class func joinSession(username: String, token: String, callback: Callback? = nil) {
        let command: String = String(format: AldoRequest.SESSION_JOIN.rawValue, token, username)
        MockAldo.request(command: command, method: .post, parameters: [:], callback: callback)
    }
    
    override open class func requestSessionInfo(callback: Callback? = nil) {
        let command: String = AldoRequest.SESSION_INFO.rawValue
        MockAldo.request(command: command, method: .get, parameters: [:], callback: callback)
    }
    
    override open class func requestSessionPlayers(callback: Callback? = nil) {
        
    }
    
    override open class func changeSessionState(newState: AldoSession.State, callback: Callback? = nil) {
        
    }
    
    override open class func deleteSession(callback: Callback? = nil) {
        
    }
    
    override open class func requestDevicePlayers(callback: Callback? = nil) {
        
    }
    
    override open class func requestPlayerInfo(callback: Callback? = nil) {
        
    }
    
    override open class func updateUsername(username: String, callback: Callback? = nil) {
        
    }
    
}
