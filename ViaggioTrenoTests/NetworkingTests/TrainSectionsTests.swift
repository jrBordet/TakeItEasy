//
//  TrainSectionsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 10/12/2020.
//

import XCTest
import Networking
import RxBlocking

class TrainSectionsTests: XCTestCase {
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
			return (httpResponse!, .train_sections)
		}
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_sections_request() {
		let sectionsRequest = Networking<TrainSectionsRequest>.sections(from: "S06000", train: "667")
		
		XCTAssertEqual(sectionsRequest.API.request.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/tratteCanvas/S06000/667")
		XCTAssertEqual(sectionsRequest.API.request.httpMethod, "GET")
	}
	
	func test_sections() throws {
		let result = try
			TrainSectionsRequest
			.fetch(from: "S06000", train: "667", urlSession: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.stazione, "LA SPEZIA CENTRALE")
		XCTAssertEqual(result?.first?.fermata.progressivo, 1)
	}
	
	func test_sections_decoding_error() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, .train_sections_broken)
		}
		
		let result =
			TrainSectionsRequest
			.fetch(from: "S06000", train: "667", urlSession: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as NSError, NSError(domain: "RxCocoa.RxCocoaURLError", code: 2, userInfo: nil))
		}
	}
	
	func test_train_sections_500() throws {
		MockUrlProtocol.requestHandler = { request in
			let httpResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: 500,
				httpVersion: nil,
				headerFields: nil
			)
			return (httpResponse!, .train_sections_broken)
		}
		
		let result =
			TrainSectionsRequest
			.fetch(from: "S06000", train: "667", urlSession: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(error as NSError, NSError(domain: "RxCocoa.RxCocoaURLError", code: 1, userInfo: nil))
		}
	}
	
}
