//
//  HomeTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 21/12/2020.
//

import XCTest
@testable import ViaggioTreno
import RxComposableArchitectureTests
import Difference
import RxComposableArchitecture
import RxSwift
import RxCocoa
import Networking

class HomeTests: XCTestCase {
	var initialState: HomeViewState!
	
	var expectedResult = Station.milano
	
	var env: HomeViewEnvironment!
	
	override func setUp() {
		initialState = HomeViewState(selectedStation: nil, departures: [], arrivals: [], stations: [], favouritesStations: [], trainNumber: nil, trainSections: [])
		
		let stationsEnv: StationsViewEnvironment = (
			autocomplete: { _ in Effect.sync { [] } },
			saveFavourites: { _ in Effect.sync { false } },
			retrieveFavourites: { Effect.sync { self.expectedResult } }
		)

		let arrivalsDeparturesViewEnv: ArrivalsDeparturesViewEnvironment = (
			departures: { _ in
				Effect.sync { [] }
			},
			arrivals: { _ in
				Effect.sync { [] }
			}
		)
		
		env = (
			stations: stationsEnv,
			arrivalsDepartures: arrivalsDeparturesViewEnv
		)
	}

	func test_retrieve_favorite_stations() {
		assert(
			initialValue: initialState,
			reducer: homeViewReducer,
			environment: env,
			steps: Step(.send, HomeViewAction.favourites(StationsViewAction.stations(StationsAction.favourites)), { _ in }),
			Step(.receive, HomeViewAction.favourites(StationsViewAction.stations(.favouritesResponse(self.expectedResult))), { state in
				state.favouritesStations = self.expectedResult
			})
		)
	}

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
