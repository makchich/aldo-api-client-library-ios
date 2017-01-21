import UIKit
import XCTest
@testable import Aldo

class AldoTests: XCTestCase, Callback {
    
    public static let deviceId = "IPHONE_SIM_DEVICE_ID"
    public static let authToken = "1111-2222-3333-4444-5555"
    
    public static let playerId = "1111-3333-5555-7777-9999"
    public static let username = "ORIGINAL_USERNAME"
    public static let changedUsername = "CHANGED_USERNAME"
    
    public static let sessionId = "0000-2222-4444-6666-8888"
    public static let creationDate = "1970-01-01T00:00:00.000"
    public static let moderatorToken = "acegik"
    public static let userToken = "bdfhj"
    
    let address: String = "127.0.0.1"
    let defaultPort: Int = 4567
    let port: Int = 8000
    
    override func setUp() {
        super.setUp()
        
        MockAldo.getStorage().removeObject(forKey: MockAldo.Keys.AUTH_TOKEN.rawValue)
        MockAldo.getStorage().removeObject(forKey: MockAldo.Keys.SESSION.rawValue)
    }
    
    override func tearDown() {
        super.tearDown()
        
        MockAldo.getStorage().removeObject(forKey: MockAldo.Keys.AUTH_TOKEN.rawValue)
        MockAldo.getStorage().removeObject(forKey: MockAldo.Keys.SESSION.rawValue)
    }
    
    func onResponse(request: String, responseCode: Int, response: NSDictionary) {
        switch request {
        case Regex(pattern: RequestURI.SESSION_PLAYERS.regex()):
            let players = response["players"] as! [Dictionary<String, Any>]
            let player = players[0]
            
            XCTAssertEqual(player["playerID"] as! String, AldoTests.playerId)
            XCTAssertEqual(player["username"] as! String, AldoTests.username)
            XCTAssertEqual(player["score"] as! Int, 0)
            break
        case Regex(pattern: RequestURI.PLAYER_ALL.regex()):
            let players = response["players"] as! [Dictionary<String, Any>]
            let player = players[0]
            
            testPlayerResponse(response: player as NSDictionary)
            break
        case Regex(pattern: RequestURI.PLAYER_INFO.regex()):
            testPlayerResponse(response: response)
            break
        case Regex(pattern: RequestURI.PLAYER_USERNAME_UPDATE.regex()):
            XCTAssertEqual(response["username"] as! String, AldoTests.changedUsername)
            break
        default:
            break
        }
    }
    
    /// Helper method to test wether all information of a player
    /// is in the response.
    private func testPlayerResponse(response: NSDictionary) {
        XCTAssertEqual(response["playerID"] as! String, AldoTests.playerId)
        XCTAssertEqual(response["username"] as! String, AldoTests.username)
        XCTAssertEqual(response["session"] as! NSDictionary, MockAldo.createSessionResponse() as NSDictionary)
        XCTAssertEqual(response["role"] as! Int, Player.Role.USER.rawValue)
        XCTAssertEqual(response["score"] as! Int, 0)
    }
    
    /// Helper method to test wether a Session object contains
    /// all information in the response.
    private func testSessionObject(session: Session, moderatorToken: String = "", userToken: String = "") {
        XCTAssertEqual(session.getId(), AldoTests.sessionId)
        XCTAssertEqual(session.getAdminId(), AldoTests.playerId)
        XCTAssertEqual(session.getModeratorToken(), moderatorToken)
        XCTAssertEqual(session.getUserToken(), userToken)
        XCTAssertEqual(session.getStatus(), Session.Status.PLAYING)
        XCTAssertEqual(session.getCreationDate(), AldoTests.creationDate)
    }
    
    func testAldoHostSetup() {
        MockAldo.setHostAddress(address: address)
        
        XCTAssertEqual(MockAldo.getHostAddress(), address)
        XCTAssertEqual(MockAldo.getPort(), defaultPort)
    }
    
    func testAldoHostSetupWithCustomPort() {
        MockAldo.setHostAddress(address: address, port: port)
        
        XCTAssertEqual(MockAldo.getHostAddress(), address)
        XCTAssertEqual(MockAldo.getPort(), port)
    }
    
    func testAldoHostSetupWithoutPort() {
        MockAldo.setHostAddress(address: address, excludePort: true)
        
        XCTAssertEqual(MockAldo.getHostAddress(), address)
        XCTAssertEqual(MockAldo.getPort(), 0)
    }
    
    func testRequestAuthToken() {
        XCTAssertFalse(MockAldo.hasAuthToken())
        MockAldo.requestAuthToken()
        XCTAssertTrue(MockAldo.hasAuthToken())
        
        if let storedToken = MockAldo.getStorage().object(forKey: MockAldo.Keys.AUTH_TOKEN.rawValue) {
            XCTAssertEqual(storedToken as! String, AldoTests.authToken)
            return
        }
        XCTFail()
    }
    
    
    func testCreateSession() {
        XCTAssertFalse(MockAldo.hasActivePlayer())
        XCTAssertNil(MockAldo.getPlayer())
        
        MockAldo.createSession(username: AldoTests.username)
        XCTAssertTrue(MockAldo.hasActivePlayer())
        
        if let player: Player = MockAldo.getPlayer() {
            XCTAssert(player.isAdmin())
            XCTAssertFalse(player.isModerator())
            XCTAssertFalse(player.isUser())
            
            XCTAssertEqual(player.getId(), AldoTests.playerId)
            XCTAssertEqual(player.getRole(), Player.Role.ADMIN)
            XCTAssertEqual(player.getScore(), 0)
            XCTAssertEqual(player.getUsername(), AldoTests.username)
            
            let session: Session = player.getSession()
            testSessionObject(session: session, moderatorToken: AldoTests.moderatorToken, userToken: AldoTests.userToken)
            return
        }
        XCTFail()
    }
    
    func testJoinSessionAsModerator() {
        XCTAssertFalse(MockAldo.hasActivePlayer())
        XCTAssertNil(MockAldo.getPlayer())
        
        MockAldo.joinSession(username: AldoTests.username, token: AldoTests.moderatorToken)
        XCTAssertTrue(MockAldo.hasActivePlayer())
        
        if let player: Player = MockAldo.getPlayer() {
            XCTAssertFalse(player.isAdmin())
            XCTAssert(player.isModerator())
            XCTAssertFalse(player.isUser())
            
            XCTAssertEqual(player.getId(), AldoTests.playerId)
            XCTAssertEqual(player.getRole(), Player.Role.MODERATOR)
            XCTAssertEqual(player.getScore(), 0)
            XCTAssertEqual(player.getUsername(), AldoTests.username)
            
            let session: Session = player.getSession()
            testSessionObject(session: session)
            return
        }
        XCTFail()
    }
    
    func testJoinSessionAsUser() {
        XCTAssertFalse(MockAldo.hasActivePlayer())
        XCTAssertNil(MockAldo.getPlayer())
        
        MockAldo.joinSession(username: AldoTests.username, token: AldoTests.userToken)
        XCTAssertTrue(MockAldo.hasActivePlayer())
        
        if let player: Player = MockAldo.getPlayer() {
            XCTAssertFalse(player.isAdmin())
            XCTAssert(player.isUser())
            XCTAssertFalse(player.isModerator())
            
            XCTAssertEqual(player.getId(), AldoTests.playerId)
            XCTAssertEqual(player.getRole(), Player.Role.USER)
            XCTAssertEqual(player.getScore(), 0)
            XCTAssertEqual(player.getUsername(), AldoTests.username)
            
            let session: Session = player.getSession()
            testSessionObject(session: session)
            return
        }
        XCTFail()
    }
    
    func testRequestSessionInfoAsAdmin() {
        testCreateSession()
        MockAldo.requestSessionInfo()
        
        if let player: Player = MockAldo.getPlayer() {
            let session: Session = player.getSession()
            testSessionObject(session: session, moderatorToken: AldoTests.moderatorToken, userToken: AldoTests.userToken)
            return
        }
        XCTFail()
    }
    
    func testRequestSessionInfo() {
        testJoinSessionAsUser()
        MockAldo.requestSessionInfo()
        
        if let player: Player = MockAldo.getPlayer() {
            let session: Session = player.getSession()
            testSessionObject(session: session)
            return
        }
        XCTFail()
    }
    
    func testRequestSessionPlayers() {
        testCreateSession()
        MockAldo.requestSessionPlayers(callback: self)
    }
    
    func testChangeSessionStatus() {
        testCreateSession()
        MockAldo.changeSessionStatus(newStatus: Session.Status.PAUSED)
        
        if let player: Player = MockAldo.getPlayer() {
            var session: Session = player.getSession()
            XCTAssertEqual(session.getStatus(), Session.Status.PAUSED)
            
            MockAldo.changeSessionStatus(newStatus: Session.Status.PLAYING)
            
            session = MockAldo.getPlayer()!.getSession()
            XCTAssertEqual(session.getStatus(), Session.Status.PLAYING)
            return
        }
        XCTFail()
    }
    
    func testDeleteSession() {
        testCreateSession()
        MockAldo.deleteSession()
        
        XCTAssertFalse(MockAldo.hasActivePlayer())
        XCTAssertNil(MockAldo.getPlayer())
    }
    
    func testRequestDevicePlayers() {
        testJoinSessionAsUser()
        MockAldo.requestDevicePlayers(callback: self)
    }
    
    func testRequestPlayerInfo() {
        testJoinSessionAsUser()
        MockAldo.requestPlayerInfo(callback: self)
    }
    
    func testUpdateUsername() {
        testJoinSessionAsUser()
        MockAldo.updateUsername(username: AldoTests.changedUsername, callback: self)
    }
}
