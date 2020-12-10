//
//  ArrivalsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 10/12/2020.
//

import XCTest
import Networking
import RxBlocking

class ArrivalsTests: XCTestCase {
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
			return (httpResponse!, .arrivals)
		}
		
	}
	
	override func tearDownWithError() throws {
	}
	
	func test_arrival_request() {
		let arrivalRequest = Networking<ArrivalsRequest>.departure(from: "S01700", date: Date(timeIntervalSince1970: 315568800))
		
		XCTAssertEqual(arrivalRequest.API.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/arrivi/S01700/Tue%20Jan%2001%201980%2010:00:00%20GMT+0100")
		XCTAssertEqual(arrivalRequest.API.request.httpMethod, "GET")
	}
	
	func test_arrivals() throws {
		let result = try
			ArrivalsRequest
			.fetch(from: "S01700", date: Date(), urlSession: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.numeroTreno, 2611)
	}
	
	func test_arrivals_decoding_error() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, .arrivals_broken)
		}
		
		let result =
			ArrivalsRequest
			.fetch(from: "S01700", date: Date(), urlSession: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as NSError, NSError(domain: "RxCocoa.RxCocoaURLError", code: 2, userInfo: nil))
		}
	}
	
	func test_arrivals_500() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 500,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, .departures_broken)
		}
		
		let result =
			ArrivalsRequest
			.fetch(from: "S01700", date: Date(), urlSession: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as NSError, NSError(domain: "RxCocoa.RxCocoaURLError", code: 1, userInfo: nil))
		}
	}
}
