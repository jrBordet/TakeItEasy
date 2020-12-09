//
//  NetworkingTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 06/12/2020.
//

import XCTest
import Networking
import RxBlocking
import RxTest

class NetworkingTests: XCTestCase {
  var urlSession: URLSession!
  
  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockUrlProtocol.self]
    
    urlSession = URLSession(configuration: configuration)
		
		let data =
			Bundle.main.path(forResource: "mock_stations", ofType: "txt")
				.map (URL.init(fileURLWithPath:))
				.flatMap { try? Data(contentsOf: $0) }
		    
    MockUrlProtocol.requestHandler = { request in
      let httpResponse = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )
      return (httpResponse!, data)
    }
    
  }
  
  override func tearDownWithError() throws {
  }
  
  func test_station_request() {
    let stationRequest = Networking<Station>.autocompleteStation(with: "mi")
    
    XCTAssertEqual(stationRequest.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mi")
    XCTAssertEqual(stationRequest.request.httpMethod, "GET")
  }
	
	func test_parse_stations() {
		let s = """
		\n  MOCK|S0666\n  MILITELLO|S12276\n  MIMMOLE|S06954\n  MINEO|S12275\n  MINERVINO MURGE|S11403\n  MINTURNO|S09150\n  MINUCCIANO - PIEVE - CASOLA|S06227\n  MIRA MIRANO|S02588\n  MIRADOLO TERME|S01867\n  MIRAMARE|S03311\n  MIRANDOLA|S05311\n  MIRTO CROSIA|S11814\n  MISANO ADRIATICO|S07119\n
		"""
		
		let stations = s.parseStations()
		
		XCTAssertEqual(stations.first?.id, "S0666")
		XCTAssertEqual(stations.first?.name, "MOCK")
	}
	
	func test_parse_stations_broken() {
		let s = """
			MOCKMOCKK|
		"""
		
		let stations = s.parseStations()
		
		XCTAssertTrue(stations.isEmpty)
	}
	
	func test_parse_stations_name_with_space() {
		let s = """
		\n  MISANO ADRIATICO|S07119\n
		"""
		
		let stations = s.parseStations()
		
		XCTAssertEqual(stations.first?.id, "S07119")
		XCTAssertEqual(stations.first?.name, "MISANO ADRIATICO")
	}
	
	func test_rx_stations_autocomplete() throws {
		let result = try
			Networking<Station>
			.autocompleteStation(with: "mi")
			.data(with: urlSession) { $0.parseStations() }
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.id, "S0666")
		XCTAssertEqual(result?.first?.name, "MOCK")
	}
	
	func test_rx_stations_autocomplete_empty_response() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, "".data(using: .utf8))
		}
		
		let result = try
			Networking<Station>
			.autocompleteStation(with: "mi")
			.data(with: urlSession) { $0.parseStations() }
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertTrue(result?.isEmpty ?? false)
	}
	
	func test_rx_stations_autocomplete_notFound_response() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, "".data(using: .utf8))
		}
		
		let result = try
			Networking<Station>
			.autocompleteStation(with: "mi")
			.data(with: urlSession) { $0.parseStations() }
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertTrue(result?.isEmpty ?? false)
	}
	
	func test_rx_stations_autocomplete_broken_response() throws {
		let data =
			Bundle
			.main
			.path(forResource: "mock_stations_broken", ofType: "txt")
			.map (URL.init(fileURLWithPath:))
			.flatMap { try? Data(contentsOf: $0) }
				
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, data)
		}
		
		let result = try
			Networking<Station>
			.autocompleteStation(with: "mi")
			.data(with: urlSession) { $0.parseStations() }
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.id, "S0666")
		XCTAssertEqual(result?.first?.name, "MOCK")
	}
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
