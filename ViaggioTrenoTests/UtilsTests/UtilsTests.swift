//
//  ZipTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 28/12/2020.
//

import XCTest
import Caprice
@testable import ViaggioTreno

class UtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_zip_optional() throws {
		let a: Int? = 1
		let b: Int? = 2
		
		let result = zip(a, b)
		
		XCTAssertEqual(result?.0, 1)
		XCTAssertEqual(result?.1, 2)
    }
	
	func test_zip_optional_with_nil() throws {
		let a: Int? = nil
		let b: Int? = 2
		
		let result = zip(a, b)
		
		XCTAssertNil(result?.0)
		XCTAssertNil(result?.1)
	}
	
	func test_status_delay_with_number() {
		let result = 1 |> trainSectionStatus()
		
		XCTAssertEqual("1'", result)
	}
	
	func test_status_delay_with_nil() {
		let result = nil |> trainSectionStatus()
		
		XCTAssertEqual("", result)
	}
	
	func test_status_delay_with_zero() {
		let result = 0 |> trainSectionStatus()
		
		XCTAssertEqual("", result)
	}

}
