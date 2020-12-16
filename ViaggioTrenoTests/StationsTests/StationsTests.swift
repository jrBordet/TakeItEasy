//
//  StationsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 15/12/2020.
//

import XCTest
@testable import ViaggioTreno
import RxComposableArchitectureTests
import Difference
import RxComposableArchitecture
import RxSwift
import RxCocoa
import Networking

class StationsTests: XCTestCase {
	var initialState: StationsViewState!
	
	var expectedResult = Station.milano
	
	var env: StationsViewEnvironment!
	
	override func setUp() {
		initialState = StationsViewState(stations: [], favouritesStations: [])
		
		env = (
			autocomplete: { _ in .sync { self.expectedResult } },
			saveFavourites: { _ in .sync { true } } ,
			retrieveFavourites: { .sync { [] }}
		)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_autocomplete_success() {
		assert(
			initialValue: initialState,
			reducer: stationsViewReducer,
			environment: env,
			steps:
				Step(.send, StationsViewAction.stations(StationsAction.autocomplete("mil")), { _ in }),
			Step(.receive, StationsViewAction.stations(StationsAction.autocompleteResponse(expectedResult)), { state in
				state.stations = self.expectedResult
			})
		)
	}
}

