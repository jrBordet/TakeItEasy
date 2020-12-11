//
//  UIStationsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import XCTest
@testable import ViaggioTreno
import SnapshotTesting
import SceneBuilder

class UIStationsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_stations_favourites_and_result() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let vc = Factory.stations
				
		assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
		assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
