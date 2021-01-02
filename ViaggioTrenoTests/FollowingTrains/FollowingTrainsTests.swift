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
	
	var selectedExpectedResult = Train.sample
	
	var env: TrainsViewEnvironment!
	
	// MARK: - Setup
	
	override func setUpWithError() throws {
		initialState = TrainsViewState(trains: [], selectedTrain: nil, error: nil)
		
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
	
	// MARK: - Tests
	
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
	
	func test_select() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.trains), { _ in }),
			Step(.receive, .trains(.trainsResponse(self.expectedResult)), { state in
				state.trains = self.expectedResult
			}),
			Step.init(.send, .trains(.select(self.selectedExpectedResult)), { state in
				state.selectedTrain = self.selectedExpectedResult
			})
		)
	}
	
	func test_add_train_success() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.add(Train.sample)), { state in
				state.trains = self.expectedResult
			}),
			Step(.receive, .trains(.updateResponse(true)), { _ in })
		)
	}
	
	func test_remove_train_success() {
		initialState = TrainsViewState(trains: [Train.sample], selectedTrain: nil, error: nil)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.remove(Train.sample)), { state in
				state.trains = []
			}),
			Step(.receive, .trains(.updateResponse(true)), { _ in })
		)
	}
	
	func test_add_train_failure() {
		env = (
			saveTrains: { _ in
				.sync {
					false
				}
			},
			retrieveTrains: {
				.sync {
					self.expectedResult
				}
			}
		)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.add(Train.sample)), { state in
				state.trains = self.expectedResult
			}),
			Step(.receive, .trains(.updateResponse(false)), { state in
				state.error = .notSaved
			})
		)
	}
	
}
