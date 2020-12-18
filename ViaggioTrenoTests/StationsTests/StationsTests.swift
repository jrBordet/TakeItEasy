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
			steps: Step(.send, StationsViewAction.stations(StationsAction.autocomplete("mil")), { _ in }),
			Step(.receive, StationsViewAction.stations(StationsAction.autocompleteResponse(expectedResult)), { state in
				state.stations = self.expectedResult
			})
		)
	}
	
	func test_add_favorite_station() {
		let station = Station("S01010", name: "TestStation")
		let station_01 = Station("S0001", name: "TestStation 1")
		
		expectedResult = [station, station_01]

		assert(
			initialValue: initialState,
			reducer: stationsViewReducer,
			environment: env,
			steps: Step(.send, StationsViewAction.stations(StationsAction.autocomplete("mil")), { _ in }),
			Step(.receive, StationsViewAction.stations(StationsAction.autocompleteResponse(expectedResult)), { state in
				state.stations = self.expectedResult
			}),
			Step(.send, StationsViewAction.stations(StationsAction.addFavorite(station)), { state in
				state.favouritesStations = [station]
				state.stations = [station_01]
			}),
			Step(.receive, StationsViewAction.stations(StationsAction.updateFavouritesResponse(true)), { state in
				
			})
		)
	}
	
	
	func test_remove_favorite_station() {
		let station = Station("S01010", name: "TestStation")
		
		assert(
			initialValue: initialState,
			reducer: stationsViewReducer,
			environment: env,
			steps: Step(.send, StationsViewAction.stations(StationsAction.addFavorite(station)), { state in
				state.favouritesStations = [station]
			}),
			Step(.receive, StationsViewAction.stations(StationsAction.updateFavouritesResponse(true)), { state in
				
			}),
			Step(.send, StationsViewAction.stations(StationsAction.removeFavourite(station)), { state in
				state.favouritesStations = []
			}),
			Step(.receive, StationsViewAction.stations(StationsAction.updateFavouritesResponse(true)), { state in
				
			}),
			Step(.send, StationsViewAction.stations(StationsAction.removeFavourite(station)), { state in
				state.favouritesStations = []
			})
		)
	}
}

