import UIKit
import XCTest
import Aldo

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
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
        MockAldo.requestAuthToken()
        
        let token: String = "1111-2222-3333-4444-5555"
        if let storedToken = MockAldo.getStorage().object(forKey: Aldo.Keys.AUTH_TOKEN.rawValue) {
            XCTAssertEqual(storedToken as! String, token)
            return
        }
        XCTFail()
    }
}
