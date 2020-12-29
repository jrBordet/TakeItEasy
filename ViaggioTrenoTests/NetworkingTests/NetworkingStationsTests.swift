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
		
		MockUrlProtocol.requestHandler = requestHandler(with: .stations, statusCode: 200)
	}
	
	override func tearDownWithError() throws {
	}
	
	func test_station_request() {
		let stationRequest = StationsRequest(station: "mi")
		
		XCTAssertEqual(stationRequest.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mi")
		XCTAssertEqual(stationRequest.request.httpMethod, "GET")
	}
	
	func test_station_request_with_spaces() {
		let stationRequest = StationsRequest(station: " mi la no   ")
		
		XCTAssertEqual(stationRequest.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/milano")
		XCTAssertEqual(stationRequest.request.httpMethod, "GET")
	}
	
	func test_station_request_with_emoji() {
		let stationRequest = StationsRequest(station: " mi la no  🍌 ")
		
		XCTAssertEqual(stationRequest.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/milano")
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
	
	func test_stations_autocomplete() throws {
		let result = try
			StationsRequest(station: "mi")
			.execute(with: urlSession, parse: { $0.parseStations() })
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.id, "S0666")
		XCTAssertEqual(result?.first?.name, "MOCK")
	}
	
	func test_stations_autocomplete_empty_response() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: "".data(using: .utf8), statusCode: 200)
		
		let result = try
			StationsRequest(station: "mi")
			.execute(with: urlSession, parse: { $0.parseStations() })
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertTrue(result?.isEmpty ?? false)
	}
	
	func test_stations_autocomplete_notFound_response() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: "".data(using: .utf8), statusCode: 200)
		
		let result = try
			StationsRequest(station: "mi")
			.execute(with: urlSession, parse: { $0.parseStations() })
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertTrue(result?.isEmpty ?? false)
	}
	
	func test_stations_autocomplete_broken_response() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .stations_broken, statusCode: 200)
		
		let result = try
			StationsRequest(station: "mi")
			.execute(with: urlSession, parse: { $0.parseStations() })
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.id, "S0666")
		XCTAssertEqual(result?.first?.name, "MOCK")
	}
	
	func test_stations_autocomplete_404() {
		MockUrlProtocol.requestHandler = requestHandler(with: .stations_broken, statusCode: 404)
		
		let result =
			StationsRequest(station: "mi")
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as? APIError, APIError.code(HTTPStatusCodes.NotFound))
		}
	}
}
