//
//  TrainSectionsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 23/12/2020.
//

import XCTest
@testable import ViaggioTreno
import RxComposableArchitectureTests
import Difference
import RxComposableArchitecture
import RxSwift
import RxCocoa
import Networking

class TrainSectionsTests: XCTestCase {
	var initialState: TrainSectionViewState!
	
	var expectedResult = TrainSectionsRequest.mock(Data.train_sections!)
	
	var env: TrainSectionViewEnvironment!
	
	override func setUp() {
		
		initialState = TrainSectionViewState(selectedStation: nil, train: nil, trainSections: [], originCode: nil)
		
		env = { _, _ in
			Effect.sync { self.expectedResult }
		}
	}
	
	func test_retrieve_favorite_stations() {
		assert(
			initialValue: initialState,
			reducer: trainSectionViewReducer,
			environment: env,
			steps: Step(.send, TrainSectionViewAction.section(TrainSectionAction.trainSections("", "")), { _ in }),
			Step(.receive, TrainSectionViewAction.section(TrainSectionAction.trainSectionsResponse(expectedResult)), { state in
				state.trainSections = self.expectedResult
			})
		)
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}
