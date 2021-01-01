//
//  TrainSectionsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 10/12/2020.
//

import XCTest
import Networking
import RxBlocking

class NetworkingTrainSectionsTests: XCTestCase {
	var urlSession: URLSession!
	
	override func setUpWithError() throws {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockUrlProtocol.self]
		
		urlSession = URLSession(configuration: configuration)
		
		MockUrlProtocol.requestHandler = requestHandler(with: .train_sections)
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_sections_request() {
		let sectionsRequest = TrainSectionsRequest(station: "S06000", train: "667")
		
		XCTAssertEqual(sectionsRequest.request?.url?.absoluteString, "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/tratteCanvas/S06000/667")
		XCTAssertEqual(sectionsRequest.request?.httpMethod, "GET")
	}
	
	func test_sections() throws {
		let result = try
			TrainSectionsRequest(station: "S06000", train: "667")
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
			.toArray()
			.first
		
		XCTAssertEqual(result?.first?.stazione, "LA SPEZIA CENTRALE")
		XCTAssertEqual(result?.first?.fermata.progressivo, 1)
	}
	
	func test_sections_decoding_error() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .train_sections_broken)
		
		let result =
			TrainSectionsRequest(station: "S06000", train: "667")
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(APIError.decoding("Decoding error on key 'last': Expected to decode Bool but found a number instead."), error as? APIError)
		}
	}
	
	func test_train_sections_500() throws {
		MockUrlProtocol.requestHandler = requestHandler(with: .train_sections_broken, statusCode: 500)
		
		let result =
			TrainSectionsRequest(station: "S06000", train: "667")
			.execute(with: urlSession)
			.toBlocking(timeout: 10)
		
		XCTAssertThrowsError(try result.toArray()) { error in
			XCTAssertEqual(APIError.code(HTTPStatusCodes.InternalServerError), error as? APIError)
		}
	}
	
}
