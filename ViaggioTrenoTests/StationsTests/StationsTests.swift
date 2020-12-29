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
	let reducer: Reducer<StationsViewState, StationsViewAction, StationsViewEnvironment> = stationsViewReducer
	
	var initialState: StationsViewState!
	
	var autocompleteResponseExpectedResult: [Station] = [
		Station("S05188", name: "MODENA PIAZZA MANZONI"),
		Station("S05997", name: "MEZZOLARA")
	]
	
	var env: StationsViewEnvironment!
	
	var selectedStationExpectedResult = Station("S05188", name: "MODENA PIAZZA MANZONI")
	
	override func setUp() {
		initialState = StationsViewState(stations: [], favouritesStations: [], selectedStation: nil)
		
		env = (
			autocomplete: { _ in .sync { self.autocompleteResponseExpectedResult } },
			saveFavourites: { _ in .sync { true } } ,
			retrieveFavourites: { .sync { [] }}
		)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	// MARK: - Tests
	
	func test_none() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(.none), { _ in
			})
		)
	}
	
	func test_select_station() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(.select(selectedStationExpectedResult)), { state in
				state.selectedStation = self.selectedStationExpectedResult
			})
		)
	}
	
	func test_autocomplete_success() {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(.autocomplete("mil")), { _ in }),
			Step(.receive, .stations(.autocompleteResponse(autocompleteResponseExpectedResult)), { state in
				state.stations = self.autocompleteResponseExpectedResult
			})
		)
	}
	
	func test_add_favorite_station() {
		let station = Station("S01010", name: "TestStation")
		let station_01 = Station("S0001", name: "TestStation 1")
		
		autocompleteResponseExpectedResult = [station, station_01]
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(StationsAction.autocomplete("mil")), { _ in }),
			Step(.receive, .stations(.autocompleteResponse(autocompleteResponseExpectedResult)), { state in
				state.stations = self.autocompleteResponseExpectedResult
			}),
			Step(.send, .stations(StationsAction.addFavorite(station)), { state in
				state.favouritesStations = [station]
				state.stations = [station_01]
			}),
			Step(.receive, .stations(.updateFavouritesResponse(true)), { state in
				
			})
		)
	}
	
	func test_add_favorite_station_already_added() {
		let station = Station("S01010", name: "TestStation")
		let station_01 = Station("S0001", name: "TestStation 1")
		
		autocompleteResponseExpectedResult = [station, station_01]
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(.autocomplete("mil")), { _ in }),
			Step(.receive, .stations(.autocompleteResponse(autocompleteResponseExpectedResult)), { state in
				state.stations = self.autocompleteResponseExpectedResult
			}),
			Step(.send, .stations(.addFavorite(station)), { state in
				state.favouritesStations = [station]
				state.stations = [station_01]
			}),
			Step(.receive, .stations(.updateFavouritesResponse(true)), { state in
				
			}),
			Step(.send, .stations(.addFavorite(station)), { state in
				state.favouritesStations = [station]
				state.stations = [station_01]
			})
		)
	}
	
	func test_add_favorite_station_not_found() {
		let station = Station("S01010", name: "TestStation")
		let station_01 = Station("S0001", name: "TestStation 1")
		
		let wrongStation = Station("wrong", name: "wrong")
		
		autocompleteResponseExpectedResult = [station, station_01]
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(.autocomplete("mil")), { _ in
			}),
			Step(.receive, .stations(.autocompleteResponse(autocompleteResponseExpectedResult)), { state in
				state.stations = self.autocompleteResponseExpectedResult
			}),
			Step(.send, .stations(.addFavorite(wrongStation)), { state in
				state.favouritesStations = []
				state.stations = self.autocompleteResponseExpectedResult
			})
		)
	}
	
	func test_remove_favorite_station() {
		let station = Station.milano.first!
		
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .stations(.autocomplete("mil")), { _ in
			}),
			Step(.receive, .stations(.autocompleteResponse(autocompleteResponseExpectedResult)), { state in
				state.stations = self.autocompleteResponseExpectedResult
			}),
			Step(.send, .stations(.addFavorite(station)), { state in
				state.favouritesStations = [station]
				state.stations = [Station.milano.last!]
			}),
			Step(.receive, .stations(.updateFavouritesResponse(true)), { state in
				
			}),
			Step(.send, .stations(.removeFavourite(station)), { state in
				state.favouritesStations = []
			}),
			Step(.receive, .stations(.updateFavouritesResponse(true)), { state in
				
			}),
			Step(.send, .stations(.removeFavourite(station)), { state in
				state.favouritesStations = []
			})
		)
	}
}

