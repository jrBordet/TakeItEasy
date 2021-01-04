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
import Caprice

class FollowingTrainsTests: XCTestCase {
	let reducer: Reducer<TrainsViewState, TrainsViewAction, TrainsViewEnvironment> = trainsViewReducer
	
	var initialState: TrainsViewState!
	
	var expectedResult: [FollowingTrain] = [
		.sample_aosta_ivrea,
		.sample_milano_torino
	]
	
	var trendSample = TrendRequest.mock(Data.trend!)
		
	var selectedTrain: FollowingTrain = .sample_aosta_ivrea
	
	var env: TrainsViewEnvironment!
	
	// MARK: - Setup
	
	override func setUpWithError() throws {
		initialState = TrainsViewState(
			trains: [],
			trends: [],
			selectedTrend: nil,
			error: nil,
			selectedTrain: selectedTrain,
			isFollowing: false
		)
		
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
					nil
					//self.trendSample
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
				state.isFollowing = true
			})
		)
	}
	
	func test_retrieve_trains_without_selected_train() {
		initialState = TrainsViewState(
			trains: [],
			trends: [],
			selectedTrend: nil,
			error: nil,
			selectedTrain: nil,
			isFollowing: false
		)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.trains), { _ in }),
			Step(.receive, .trains(.trainsResponse(self.expectedResult)), { state in
				state.trains = self.expectedResult
				state.isFollowing = false
			})
		)
	}
	
	func test_follow_train_start_follow() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.follow(.sample_aosta_ivrea)), { state in
				state.trains = [.sample_aosta_ivrea]
				state.selectedTrain = .sample_aosta_ivrea
				state.isFollowing = true
			}),
			Step(.receive, .trains(.updateResponse(true)), { _ in })
		)
	}
	
	func test_follow_train_stop_follow() {
		let selectedTrain = FollowingTrain.sample_aosta_ivrea
		
		initialState = TrainsViewState(
			trains: [.sample_aosta_ivrea],
			trends: [],
			selectedTrend: nil,
			error: nil,
			selectedTrain: selectedTrain,
			isFollowing: false
		)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.follow(selectedTrain)), { state in
				state.trains = []
				state.selectedTrain = selectedTrain
				state.isFollowing = false
			}),
			Step(.receive, .trains(.updateResponse(true)), { _ in })
		)
	}
	
	func test_remove_train_success() {
		let selectedTrain = FollowingTrain.sample_aosta_ivrea
		
		initialState = TrainsViewState(
			trains: [
				.sample_aosta_ivrea
			],
			trends: [],
			selectedTrend: nil,
			error: nil,
			selectedTrain: selectedTrain,
			isFollowing: false
		)
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .trains(.remove(selectedTrain)), { state in
				state.trains = []
				state.isFollowing = false
			}),
			Step(.receive, .trains(.updateResponse(true)), { _ in })
		)
	}
	
	func test_add_train_failure() {
		initialState = TrainsViewState(
			trains: [
			],
			trends: [],
			selectedTrend: nil,
			error: nil,
			selectedTrain: selectedTrain,
			isFollowing: false
		)
		
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
			steps: Step(.send, .trains(.follow(selectedTrain)), { state in
				state.trains = [self.selectedTrain]
				state.selectedTrain = self.selectedTrain
				state.isFollowing = true
			}),
			Step(.receive, .trains(.updateResponse(false)), { state in
				state.error = .notSaved
			})
		)
	}
	
//	func test_select_train() {
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.selectTrain(selectedTrain)), { state in
//				state.selectedTrain = self.selectedTrain
//			})
//		)
//	}
	
//	func test_select_trend() {
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.trains), { _ in }),
//			Step(.receive, .trains(.trainsResponse(self.expectedResult)), { state in
//				state.trends = self.expectedResult
//			}),
//			Step(.send, .trains(.select(trendSample)), { state in
//				state.selectedTrend = self.trendSample
//			})
//		)
//	}
	
//	func test_is_following_train() {
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.selectTrain(selectedTrain)), { state in
//				state.selectedTrain = self.selectedTrain
//			}),
//			Step(.send, .trains(.trains), { _ in }),
//			Step(.receive, .trains(.trainsResponse(self.expectedResult)), { state in
//				state.trains = self.expectedResult
//												
//				state.selectedTrain = self.selectedTrain |> \.isFollowing *~ true
//			})
//		)
//	}
//	
//	func test_is_not_following_train() {
//		selectedTrain = self.selectedTrain
//			|> \SelectedTrain.originCode *~ "S00000"
//			|> \SelectedTrain.trainNumber *~ "000"
//					
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.selectTrain(self.selectedTrain)), { state in
//				state.selectedTrain = self.selectedTrain
//			}),
//			Step(.send, .trains(.trains), { _ in }),
//			Step(.receive, .trains(.trainsResponse(self.expectedResult)), { state in
//				state.trains = self.expectedResult
//				state.selectedTrain = self.selectedTrain
//			})
//		)
//	}
	
//	func test_add_train_success() {
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.add(trendSample)), { state in
//				state.trends = self.expectedResult
//				state.selectedTrain = self.selectedTrain |> \.isFollowing *~ true
//			}),
//			Step(.receive, .trains(.updateResponse(true)), { state in
//
//			})
//		)
//	}
//
//	func test_remove_train_success() {
//		initialState = TrainsViewState(trains: [], trends: [trendSample], selectedTrend: nil, error: nil, selectedTrain: nil)
//
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.remove(trendSample)), { state in
//				state.trends = []
//			}),
//			Step(.receive, .trains(.updateResponse(true)), { _ in })
//		)
//	}
//
//	func test_add_train_failure() {
//		env = (
//			saveTrains: { _ in
//				.sync {
//					false
//				}
//			},
//			retrieveTrains: {
//				.sync {
//					self.expectedResult
//				}
//			},
//			retrieveTrend: { _, _ in
//				Effect.sync { nil }
//			}
//		)
//
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.add(trendSample)), { state in
//				state.trends = self.expectedResult
//				state.selectedTrain = self.selectedTrain
//			}),
//			Step(.receive, .trains(.updateResponse(false)), { state in
//				state.error = .notSaved
//			})
//		)
//	}
//
//	func test_retreive_trend_success() {
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.trend("S00137", "2776")), { state in
//				state.selectedTrain = FollowingTrain(originCode: "S00137", trainNumber: "2776", isFollowing: false)
//			}),
//			Step(.receive, .trains(.trendResponse(trendSample)), { _ in }),
//			Step(.receive, .trains(.add(trendSample)), { state in
//				state.trends = [self.trendSample]
//				state.selectedTrain = self.selectedTrain
//			}),
//			Step(.receive, .trains(.updateResponse(true)), { _ in })
//		)
//	}
//
//	func test_retreive_trend_failure() {
//		env = (
//			saveTrains: { _ in
//				.sync {
//					true
//				}
//			},
//			retrieveTrains: {
//				.sync {
//					[]
//				}
//			},
//			retrieveTrend: { _, _ in
//				.sync {
//					nil
//				}
//			}
//		)
//
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .trains(.trend("S00137", "2776")), { state in
//				state.selectedTrain = FollowingTrain(originCode: "S00137", trainNumber: "2776", isFollowing: false)
//			}),
//			Step(.receive, .trains(.trendResponse(nil)), { state in
//				state.trends = []
//			})
//		)
//	}
	
}
