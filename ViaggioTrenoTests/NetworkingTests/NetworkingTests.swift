//
//  NetworkingTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 06/12/2020.
//

import XCTest
import Networking

class NetworkingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_travel_request() throws {
      let result = TravelRequest(station: "mi")
      
      XCTAssertEqual(result.endpoint, "/autocompletaStazione")
      XCTAssertEqual(result.request.httpMethod, "GET")
      XCTAssertEqual(result.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno//autocompletaStazionemi")
      
      //performAPI(request: <#T##APIRequest#>, completion: <#T##(Result<Decodable>) -> Void#>)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
