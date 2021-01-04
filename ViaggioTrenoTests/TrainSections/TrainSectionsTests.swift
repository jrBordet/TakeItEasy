//
//  TrainSectionsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 23/12/2020.
//

import XCTest
@testable import PendolareStanco
import RxComposableArchitectureTests
import Difference
import RxComposableArchitecture
import RxSwift
import RxCocoa
import Networking

class TrainSectionsTests: XCTestCase {
	let reducer: Reducer<TrainSectionViewState, TrainSectionViewAction, TrainSectionViewEnvironment> = trainSectionViewReducer
	
	var initialState: TrainSectionViewState!
	
	var expectedResult = TrainSectionsRequest.mock(Data.train_sections!)
	var selectedStationExpectedResult = Station("S05188", name: "MODENA PIAZZA MANZONI")
	var currentTrain = CurrentTrain(number: "S0129", name: "Milano", status: "in orario", originCode: "S1245")
	
	var trendExpectResult = TrendRequest.mock(Data.trend!)
	var trendSample = TrendRequest.mock(Data.trend!)
	
	var env: TrainSectionViewEnvironment!
	
	override func setUp() {
		initialState = TrainSectionViewState(
			selectedStation: nil,
			train: nil,
			trainSections: [],
			originCode: nil,
			isRefreshing: false,
			followingTrainsState:
				TrainsViewState(
					trains: [],
					trends: [],
					selectedTrend: nil,
					error: nil,
					selectedTrain: nil,
					isFollowing: false
				)
		)
		
		let followingEnvMock: TrainsViewEnvironment = (
			saveTrains: { _ in
				Effect.sync {
					true
				}
			},
			retrieveTrains: {
				Effect.sync {
					[] // self.trendExpectResult
				}
			},
			retrieveTrend: { _, _ in
				Effect.sync { nil }
			}
		)
		
		let sectionsEnv: TrainSectionViewEnvironment = (
			sections: { _, _ in Effect.sync { self.expectedResult } },
			followingTrains: followingEnvMock
		)
		
		env = sectionsEnv
	}
	
	func test_retrieve_favorite_stations() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .section(.trainSections("", "")), { _ in }),
			Step(.receive, .section(.trainSectionsResponse(expectedResult)), { state in
				state.trainSections = self.expectedResult
			})
		)
	}
	
	func test_select_station() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .section(.select(selectedStationExpectedResult)), { state in
				state.selectedStation = self.selectedStationExpectedResult
			})
		)
	}
	
	func test_refresh() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .section(.refresh("", "")), { state in
				state.isRefreshing = true
			}),
			Step(.receive, .section(.trainSectionsResponse(expectedResult)), { state in
				state.isRefreshing = false
				state.trainSections = self.expectedResult
			})
		)
	}
	
	func test_select_train() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .section(.selectTrain(currentTrain)), { state in
				state.train = self.currentTrain
			})
		)
	}
	
//	func test_follow_train() {
//		assert(
//			initialValue: initialState,
//			reducer: reducer,
//			environment: env,
//			steps: Step(.send, .following(.trains(.add(trendSample))), { state in
//				state.followingTrainsState = TrainsViewState(trains: [self.trendSample], selectedTrend: nil, error: nil, selectedTrain: nil)
//			}),
//			Step(.receive, .following(.trains(.updateResponse(true))), { state in
//
//			})
//		)
//	}
}
