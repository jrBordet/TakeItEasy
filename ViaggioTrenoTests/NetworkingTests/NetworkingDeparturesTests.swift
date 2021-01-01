//
//  DeparturesTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 10/12/2020.
//

import XCTest
import Networking
import RxBlocking

class DeparturesTests: XCTestCase {
	var urlSession: URLSession!
	
	override func setUpWithError() throws {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockUrlProtocol.self]
		
		urlSession = URLSession(configuration: configuration)
		
		MockUrlProtocol.requestHandler = requestHandler(with: .departures)
	}
	
	override func tearDownWithError() throws {
	}
	
	func test_departure_request() {
		let departuresRequest = DeparturesRequest(code: "S01700", date: Date(timeIntervalSince1970: 315568800))
		
		XCTAssertEqual(departuresRequest.request?.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/partenze/S01700/Tue%20Jan%2001%201980%2010:00:00%20GMT+0100")
		XCTAssertEqual(departuresRequest.request?.httpMethod, "GET")
	}
	
	func test_departures() throws {
		let result = try
			DeparturesRequest(code: "S01700", date: Date())
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(9523, result?.first?.numeroTreno)
	}
	
	func test_departures_decoding_error() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .departures_broken)
		
		let result =
			DeparturesRequest(code: "S01700", date: Date())
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as? APIError, APIError.decoding("Decoding error on key 'numeroTreno': Expected to decode Int but found a string/data instead."))
		}
	}
	
	func test_departures_500() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .departures_broken, statusCode: 500)
		
		let result =
			DeparturesRequest(code: "S01700", date: Date())
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as? APIError, APIError.code(HTTPStatusCodes.InternalServerError))
		}
	}
	
}
