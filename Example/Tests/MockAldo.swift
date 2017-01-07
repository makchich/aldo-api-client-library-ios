import Foundation
import Aldo

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
        mockAddress = address
        mockPort = port
    }
    
    override public class func requestAuthToken(callback: Callback? = nil) {
        
    }
    
    override public class func createSession(username: String, callback: Callback? = nil) {
        
    }
    
    override public class func joinSession(username: String, token: String, callback: Callback? = nil) {
        
    }
    
    override open class func requestSessionInfo(callback: Callback? = nil) {
        
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
