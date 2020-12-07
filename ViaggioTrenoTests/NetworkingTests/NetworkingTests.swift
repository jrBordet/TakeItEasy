//
//  NetworkingTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 06/12/2020.
//

import XCTest
import Networking

class MockUrlProtocol: URLProtocol {
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    guard let handler = MockUrlProtocol.requestHandler else {
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
    var urlSession: URLSession!
  
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
      
      let configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [MockUrlProtocol.self]
      
      urlSession = URLSession(configuration: configuration)
      
      // aoirequestload(reuqest, session)
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
      
//      let task = performAPI(request: result) { result in
//        switch result {
//        case let .success(data):
//          break
//        case let .failure(error):
//          XCTFail(error.localizedDescription)
//        }
//
//        expectation.fulfill()
//      }
      
//      XCTAssertNotNil(task)
      
      let mock = """
      {
       MOCK|S0666
       MONTESANTO|S05801
       MONTESILVANO|S07808
       MONTEU DA PO|S00422
       MONTEVARCHI TERRANUOVA|S06910
       MONTEVERDE|S09624
       MONTI TELTI|S12857
       MONTICCHIO|S09622
       MONTICELLI D`ONGINA|S01971
       MONTICELLO D`ALBA|S00823
       MONTIGLIO MURISENGO|S00426
       MONTIRONE|S01840
       MONTJOVET|S00144
       MONTORO FORINO|S09518
       MONTORO SUPERIORE|S09517
       MONTORSI|S09528
       MONTORSOLI|S06601
       MONTREUX|S01235
       MONZA|S01322
       MONZA SOBBORGHI|S01480
       MONZONE-M.DEI BANCHI-ISOLANO|S06225
       MONZUNO|S05132
       MORANO SUL PO|S00177
       MORBEGNO|S01425
       MORCONE|S09503
      }
      """.data(using: .utf8)!
      
      MockUrlProtocol.requestHandler = { request in
        let httpResponse = HTTPURLResponse(
          url: result.request.url!,
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )
        return (httpResponse!, mock)
      }
      
      performAPI(session: urlSession, request: result) { result in
        switch result {
        case let .success(data):
          print(String(data: data, encoding: .utf8))
        case .failure(_):
          XCTFail("")
        }
        
        expectation.fulfill()
      }

      
      wait(for: [expectation], timeout: 10.0)
    }
  
  func test_request() {

    
  }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
