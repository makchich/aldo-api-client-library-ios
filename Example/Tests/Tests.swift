import UIKit
import XCTest
import Aldo

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        Aldo.setHostAddress(address: "https://expeditionmundus.herokuapp.com")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestAuthToken() {
//        let exp: XCTestExpectation = expectation(description: "First Time Auth Token Request")
//        
//        let callback: MockCallback = MockCallback(expectation: exp)
//        Aldo.requestAuthToken(callback: callback)
//        
//        self.waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "Something went horribly wrong")
//            XCTAssertEqual(callback.getResponseCode(), 401)
//            XCTAssertEqual(callback.getResponse(), [:])
//        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}


public class MockCallback: Callback {
    
    private var expectation: XCTestExpectation
    
    private var responseCode: Int
    private var response: NSDictionary
    
    public init(expectation: XCTestExpectation) {
        self.expectation = expectation
        self.responseCode = 401
        self.response = [:]
    }
    
    public func onResponse(responseCode: Int, response: NSDictionary) {
        self.responseCode = responseCode
        self.response = response
        
        expectation.fulfill()
    }
    
    public func getResponseCode() -> Int {
        return responseCode
    }
    
    public func getResponse() -> NSDictionary {
        return response
    }
    
}
