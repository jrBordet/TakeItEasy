//
//  UIStationsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import XCTest
@testable import PendolareStanco
import RxComposableArchitectureTests
import SnapshotTesting
import Difference
import SceneBuilder
import RxComposableArchitecture
import Networking

class UIStationsTests: XCTestCase {
	var initialState: StationsViewState!
	
	var expectedResult = Station.milano
	
	var env: StationsViewEnvironment!
	
	override func setUp() {
		initialState = StationsViewState(stations: [], favouritesStations: [], selectedStation: nil)
		
		env = (
			autocomplete: { _ in .sync { self.expectedResult } },
			saveFavourites: { _ in .sync { true } } ,
			retrieveFavourites: { .sync { Station.milano }}
		)
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_stations_favourites_and_result() throws {
		let vc = Factory.stations
		
		let station = Station("S01010", name: "TestStation")
		let station_01 = Station("S0001", name: "TestStation 1")
		
		expectedResult = [station, station_01]

		vc.store = Store<StationsViewState, StationsViewAction>(
			initialValue: StationsViewState(stations:[], favouritesStations: [], selectedStation: nil),
			reducer: stationsViewReducer,
			environment: env
		)
				
		assert(
			initialValue: initialState,
			reducer: stationsViewReducer,
			environment: env,
			steps: Step(.send, StationsViewAction.stations(StationsAction.autocomplete("mil")), { state in
				state.stations = []
				state.favouritesStations = []
			}),
			Step(.receive, StationsViewAction.stations(StationsAction.autocompleteResponse(expectedResult)), { state in
				state.stations = self.expectedResult
				
//				assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
			}),
			Step(.send, StationsViewAction.stations(StationsAction.addFavorite(station)), { state in
				state.favouritesStations = [station]
				state.stations = [station_01]
			}),
			Step(.receive, StationsViewAction.stations(StationsAction.updateFavouritesResponse(true)), { state in
//				assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
			})
		)
	}
	
}
