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
		
		MockUrlProtocol.requestHandler = requestHandler(with: .arrivals)
	}
	
	override func tearDownWithError() throws {
	}
	
	func test_arrival_request() {
		let arrivalRequest = ArrivalsRequest(code: "S01700", date: Date(timeIntervalSince1970: 315568800))
		
		XCTAssertEqual(arrivalRequest.request?.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/arrivi/S01700/Tue%20Jan%2001%201980%2010:00:00%20GMT+0100")
		XCTAssertEqual(arrivalRequest.request?.httpMethod, "GET")
	}
	
	func test_arrivals() throws {
		let result = try ArrivalsRequest(code: "S01700", date: Date())
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(25523, result?.first?.numeroTreno)
	}
	
	func test_arrivals_decoding_error() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .arrivals_broken)
		
		do {
			_ = try ArrivalsRequest(code: "S01700", date: Date())
				.execute(with: urlSession)
				.toBlocking(timeout: 30)
				.toArray()
		} catch let error {
			XCTAssertEqual(error as? APIError, APIError.decoding("Decoding error on key 'numeroTreno': Expected to decode Int but found a string/data instead."))
		}
	}
	
	func test_arrivals_500() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .departures_broken, statusCode: 500)
		
		do {
			_ = try ArrivalsRequest(code: "S01700", date: Date())
				.execute(with: urlSession)
				.toBlocking(timeout: 10)
				.toArray()
		}  catch let error {
			XCTAssertEqual(error as? APIError, APIError.code(HTTPStatusCodes.InternalServerError))
		}
	}
}
