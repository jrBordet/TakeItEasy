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
		
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, .departures)
		}
		
	}
	
	override func tearDownWithError() throws {
	}
	
	func test_departure_request() {
		let departuresRequest = Networking<DeparturesRequest>.departure(from: "S01700", date: Date(timeIntervalSince1970: 315568800))
		
		XCTAssertEqual(departuresRequest.API.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/partenze/S01700/Tue%20Jan%2001%201980%2010:00:00%20GMT+0100")
		XCTAssertEqual(departuresRequest.API.request.httpMethod, "GET")
	}
	
	func test_departures() throws {
		let result = try
			DeparturesRequest
			.fetch(from: "S01700", date: Date(), urlSession: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.numeroTreno, 2611)
	}
	
	func test_departures_decoding_error() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, .departures_broken)
		}
		
		let result =
			DeparturesRequest
			.fetch(from: "S01700", date: Date(), urlSession: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as NSError, NSError(domain: "RxCocoa.RxCocoaURLError", code: 2, userInfo: nil))
		}
	}
	
	func test_departures_500() throws {
		let data =
			Bundle.main.path(forResource: "departures_broken", ofType: ".json")
			.map (URL.init(fileURLWithPath:))
			.flatMap { try? Data(contentsOf: $0) }
		
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 500,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, data)
		}
		
		let result =
			DeparturesRequest
			.fetch(from: "S01700", date: Date(), urlSession: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as NSError, NSError(domain: "RxCocoa.RxCocoaURLError", code: 1, userInfo: nil))
		}
	}
	
}
