//
//  FollowingTrainsTests.swift
//  PendolareStancoTests
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import XCTest
@testable import PendolareStanco
import RxComposableArchitectureTests
import Difference
import RxComposableArchitecture
import RxSwift
import RxCocoa
import Networking

class FollowingTrainsTests: XCTestCase {
	let reducer: Reducer<TrainsViewState, TrainsViewAction, TrainsViewEnvironment> = trainsViewReducer
	
	var initialState: TrainsViewState!
	
	var expectedResult: [Train] = [
		Train.sample
	]
	
	var env: TrainsViewEnvironment!
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		initialState = TrainsViewState(trains: [], selectedTrain: nil)
		
		env = (
			saveTrains: { _ in
				.sync {
					true
				}
			},
			retrieveTrains: {
				.sync {
					self.expectedResult
				}
			}
		)
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_retrieve_trains() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.trains), { _ in }),
			Step(.receive, .trains(.trainsResponse(self.expectedResult)), { state in
				state.trains = self.expectedResult
			})
		)
	}
	
}
