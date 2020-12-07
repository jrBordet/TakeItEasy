//
//  NetworkingTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 06/12/2020.
//

import XCTest
import Networking
class MockUrlProtocol: URLProtocol {
  static var reuqestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    guard let handler = MockUrlProtocol.reuqestHandler else {
      fatalError("no handler set")
    }
    
    do {
      let (response, data) =  try handler(request)
      
      guard let d = data else {
        fatalError("data is empty")
      }
      
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: d)
      client?.urlProtocolDidFinishLoading(self)
      
    } catch let e {
      client?.urlProtocol(self, didFailWithError: e)
    }
    
  }
  
  override func stopLoading() {
    
  }
}

class NetworkingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_travel_request() throws {
      let expectation = XCTestExpectation(description: "Download apple.com home page")

      let result = TravelRequest(station: "mi")
      
      XCTAssertEqual(result.endpoint, "/autocompletaStazione")
      XCTAssertEqual(result.request.httpMethod, "GET")
      XCTAssertEqual(result.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mi")
      
      let task = performAPI(request: result) { result in
        switch result {
        case let .success(data):
          break
        case let .failure(error):
          XCTFail(error.localizedDescription)
        }
        
        expectation.fulfill()
      }
      
      XCTAssertNotNil(task)
      
      wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
