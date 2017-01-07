import UIKit
import XCTest

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
}
