//
//  ZipTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 28/12/2020.
//

import XCTest
@testable import ViaggioTreno

class ZipTests: XCTestCase {

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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
