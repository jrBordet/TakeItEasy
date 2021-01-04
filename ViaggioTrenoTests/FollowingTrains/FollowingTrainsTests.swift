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
	
	var expectedResult: [Trend] = [
		TrendRequest.mock(Data.trend!)
	]
	
	var trendSample = TrendRequest.mock(Data.trend!)
	
	var selectedExpectedResult = Train.sample
	
	var env: TrainsViewEnvironment!
	
	// MARK: - Setup
	
	override func setUpWithError() throws {
		initialState = TrainsViewState(trains: [], selectedTrend: nil, error: nil)
		
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
			},
			retrieveTrend: { _, _ in
				.sync {
					self.trendSample
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
			Step.init(.send, .trains(.select(trendSample)), { state in
				state.selectedTrend = self.trendSample
			})
		)
	}
	
	func test_add_train_success() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.add(trendSample)), { state in
				state.trains = self.expectedResult
			}),
			Step(.receive, .trains(.updateResponse(true)), { _ in })
		)
	}
	
	func test_remove_train_success() {
		initialState = TrainsViewState(trains: [trendSample], selectedTrend: nil, error: nil)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.remove(trendSample)), { state in
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
			},
			retrieveTrend: { _, _ in
				Effect.sync { nil }
			}
		)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.add(trendSample)), { state in
				state.trains = self.expectedResult
			}),
			Step(.receive, .trains(.updateResponse(false)), { state in
				state.error = .notSaved
			})
		)
	}
	
	func test_retreive_trend_success() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.trend("origin", "train")), { state in
			}),
			Step(.receive, .trains(.trendResponse(trendSample)), { state in
			}),
			Step(.receive, TrainsViewAction.trains(TrainsAction.add(trendSample)), { state in
				state.trains = [self.trendSample]
			}),
			Step(.receive, .trains(.updateResponse(true)), { state in
			})
		)
	}
	
	func test_retreive_trend_failure() {
		env = (
			saveTrains: { _ in
				.sync {
					true
				}
			},
			retrieveTrains: {
				.sync {
					[]
				}
			},
			retrieveTrend: { _, _ in
				.sync {
					nil
				}
			}
		)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.trend("origin", "train")), { state in
			}),
			Step(.receive, .trains(.trendResponse(nil)), { state in
				state.trains = []
			})
		)
	}
	
}
