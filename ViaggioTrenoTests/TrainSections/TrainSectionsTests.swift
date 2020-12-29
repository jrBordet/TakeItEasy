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
	let reducer: Reducer<TrainSectionViewState, TrainSectionViewAction, TrainSectionViewEnvironment> = trainSectionViewReducer

	var initialState: TrainSectionViewState!
	
	var expectedResult = TrainSectionsRequest.mock(Data.train_sections!)
	var selectedStationExpectedResult = Station("S05188", name: "MODENA PIAZZA MANZONI")
	var currentTrain = CurrentTrain(number: "S0129", name: "Milano", status: "in orario", originCode: "S1245")

	var env: TrainSectionViewEnvironment!
	
	override func setUp() {
		initialState = TrainSectionViewState(selectedStation: nil, train: nil, trainSections: [], originCode: nil)
		
		env = { _, _ in
			.sync { self.expectedResult }
		}
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
}
