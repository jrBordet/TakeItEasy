//
//  NetworkingTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 06/12/2020.
//

import XCTest
import Networking

let mock = """
{
  MOCK|S0666
  MILITELLO|S12276
  MIMMOLE|S06954
  MINEO|S12275
  MINERVINO MURGE|S11403
  MINTURNO|S09150
  MINUCCIANO - PIEVE - CASOLA|S06227
  MIRA MIRANO|S02588
  MIRADOLO TERME|S01867
  MIRAMARE|S03311
  MIRANDOLA|S05311
  MIRTO CROSIA|S11814
  MISANO ADRIATICO|S07119
}
""".data(using: .utf8)!

class NetworkingTests: XCTestCase {
  var urlSession: URLSession!
  
  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockUrlProtocol.self]
    
    urlSession = URLSession(configuration: configuration)
    
    MockUrlProtocol.requestHandler = { request in
      let httpResponse = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )
      return (httpResponse!, mock)
    }
    
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func test_parallel() {
    let expectation = XCTestExpectation(description: "Download apple.com home page")
    //Networking.travel.request
    
    Parallel<Result<String>> { [weak self] callback in
      let url = "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/M"

      let dataTask = self?.urlSession.dataTask(with: URLRequest(url: URL(string: url)!)) { data, response, error in
        guard
          let data = data,
          let result = String(data: data, encoding: .utf8) else {
          callback(.failure(NSError.init(domain: error?.localizedDescription ?? "", code: 1, userInfo: nil)))
          return
        }
        
        callback(.success(result))
      }.resume()
      
    }.run {
      switch $0 {
      case let .success(v):
        dump(v)
        break
      case .failure(_):
        break
      }
      expectation.fulfill()
    }

//    let p = Parallel<String> { [weak self] (callback: @escaping (String) -> Void) in
//      let url = "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/M"
//      print("\(url)")
//
//      let dataTask = self?.urlSession.dataTask(with: URLRequest(url: URL(string: url)!)) { data, response, error in
//        guard
//          let data = data,
//          let result = String(data: data, encoding: .utf8) else {
//          return
//        }
//        callback(result)
//      }
//
//      dataTask?.resume()
//
//      return
//    }
//
//    p.run { r in
//      dump(r)
//
////      expectation.fulfill()
//    }
    
//    let pt = Parallel<TravelRequest> { (request: @escaping (TravelRequest) -> Void) in
//      return
//    }
//
//    pt.run { result in
//      dump(result)
//    }
    
    wait(for: [expectation], timeout: 30.0)
  }
  
  func test_travel() {
    let request = Networking<Travel>.autocompleteStation(with: "mi")
    
    XCTAssertEqual(request.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mi")
    XCTAssertEqual(request.request.httpMethod, "GET")
  }
  
  func test_travel_networking() throws {
    let expectation = XCTestExpectation(description: "Download apple.com home page")
    
    MockUrlProtocol.requestHandler = { request in
      let httpResponse = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )
      return (httpResponse!, mock)
    }
    
    let request = Networking<Travel>
      .autocompleteStation(with: "mi")
      .performAPI(urlSession: urlSession) { result in
        switch result {
        case let .success(data):
          let s = String(data: data, encoding: .utf8) ?? ""
          XCTAssertTrue(s.contains("MOCK"))
        case .failure(_):
          XCTFail("")
        }
        
        expectation.fulfill()
      }
    
    XCTAssertNotNil(request)
    
    wait(for: [expectation], timeout: 10.0)
  }
  
  func test_travel_networking_2() throws {
    let expectation = XCTestExpectation(description: "Download apple.com home page")
    
    MockUrlProtocol.requestHandler = { request in
      let httpResponse = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )
      return (httpResponse!, mock)
    }
    
    let request = Networking<Travel>
      .autocompleteStation(with: "mi")
      .performAPI(urlSession: urlSession) { result in
        switch result {
        case let .success(data):
          let s = String(data: data, encoding: .utf8) ?? ""
          XCTAssertTrue(s.contains("MOCK"))
        case .failure(_):
          XCTFail("")
        }

        expectation.fulfill()
      }
    
    XCTAssertNotNil(request)
    
    wait(for: [expectation], timeout: 10.0)
  }
  
  func test_travel_networking_3() throws {
    let expectation = XCTestExpectation(description: "Download apple.com home page")

    let request = Parallel<TravelRequest> { (callback: @escaping (TravelRequest) -> Void) in
      callback(TravelRequest(station: ""))
    }
    
    request.run { result in
      dump(result)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 10.0)
  }

  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
