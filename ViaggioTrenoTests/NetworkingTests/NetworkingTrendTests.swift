//
//  NetworkingTrendTests.swift
//  PendolareStancoTests
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import XCTest
import Networking
import RxBlocking

class NetworkingTrendTests: XCTestCase {
	var urlSession: URLSession!

	override func setUpWithError() throws {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockUrlProtocol.self]
		
		urlSession = URLSession(configuration: configuration)
		
		MockUrlProtocol.requestHandler = requestHandler(with: .trend)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_trend_request() {
		let sectionsRequest = TrendRequest(origin: "S00137", train: "11824")
		
		XCTAssertEqual(sectionsRequest.request?.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/andamentoTreno/S00137/11824")
		XCTAssertEqual(sectionsRequest.request?.httpMethod, "GET")
	}

	func test_trend() throws {
		let result = try
			TrendRequest(origin: "S00137", train: "11824")
			.execute(with: urlSession)
			.catchError{ e  in
				fatalError(e.localizedDescription)
			}
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual("AOSTA", result?.origine)
		XCTAssertEqual("1:11", result?.compDurata)
	}

	func test_trend_decoding_error() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .trend_broken)
		
		let result =
			TrendRequest(origin: "S00137", train: "11824")
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(APIError.decoding("Decoding error on key 'stazione': Expected to decode String but found a number instead."), error as? APIError)
		}
	}

	func test_train_sections_500() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .trend_broken, statusCode: 500)
		
		let result =
			TrendRequest(origin: "S00137", train: "11824")
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(APIError.code(HTTPStatusCodes.InternalServerError), error as? APIError)
		}
	}

}

