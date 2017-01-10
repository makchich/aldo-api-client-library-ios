import UIKit
import XCTest
@testable import Aldo

class Tests: XCTestCase {
    
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
    
    func testAldoHostSetup() {
        let address: String = "127.0.0.1"
        let port: Int = 8000
        MockAldo.setHostAddress(address: address, port: port)
        
        XCTAssertEqual(MockAldo.getHostAddress(), address)
        XCTAssertEqual(MockAldo.getPort(), port)
    }
    
    func testAldoHostSetupWithoutPort() {
        let address: String = "127.0.0.1"
        let port: Int = 4567
        MockAldo.setHostAddress(address: address)
        
        XCTAssertEqual(MockAldo.getHostAddress(), address)
        XCTAssertEqual(MockAldo.getPort(), port)
    }
    
    func testRequestAuthToken() {
        XCTAssertFalse(MockAldo.hasAuthToken())
        MockAldo.requestAuthToken()
        XCTAssertTrue(MockAldo.hasAuthToken())
        
        let token: String = "1111-2222-3333-4444-5555"
        if let storedToken = MockAldo.getStorage().object(forKey: MockAldo.Keys.AUTH_TOKEN.rawValue) {
            XCTAssertEqual(storedToken as! String, token)
            return
        }
        XCTFail()
    }
    
    func testCreateSession() {
        XCTAssertNil(MockAldo.getStoredSession())
        XCTAssertFalse(MockAldo.hasSession())
        
        var username: String = "create_session_test_username"
        MockAldo.createSession(username: username)
        XCTAssertTrue(MockAldo.hasSession())
        
        if let session: AldoSession = MockAldo.getStoredSession() {
            XCTAssertEqual(session.getSessionID(), "0000-2222-4444-6666-8888")
            XCTAssertEqual(session.getPlayerID(), "1111-3333-5555-7777-9999")
            XCTAssertEqual(session.getModToken(), "acegik")
            XCTAssertEqual(session.getUserToken(), "bdfhj")
            XCTAssertEqual(session.getUsername(), username)
            XCTAssertTrue(session.isAdmin())
            
            username = "changed_user_name"
            session.setUsername(username: username)
            XCTAssertEqual(session.getUsername(), username)
            return
        }
        XCTFail()
    }
    
    func testJoinSession() {
        XCTAssertNil(MockAldo.getStoredSession())
        XCTAssertFalse(MockAldo.hasSession())
        
        var username: String = "join_session_test_username"
        MockAldo.joinSession(username: username, token: "abcdef")
        XCTAssertTrue(MockAldo.hasSession())
        
        if let session: AldoSession = MockAldo.getStoredSession() {
            XCTAssertEqual(session.getSessionID(), "0000-2222-4444-6666-8888")
            XCTAssertEqual(session.getPlayerID(), "1111-3333-5555-7777-9999")
            XCTAssertEqual(session.getModToken(), "")
            XCTAssertEqual(session.getUserToken(), "")
            XCTAssertEqual(session.getUsername(), username)
            XCTAssertFalse(session.isAdmin())
            
            username = "changed_user_name"
            session.setUsername(username: username)
            XCTAssertEqual(session.getUsername(), username)
            return
        }
        XCTFail()
    }
}
