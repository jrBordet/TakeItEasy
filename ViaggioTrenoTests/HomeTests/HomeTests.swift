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
	let reducer: Reducer<HomeViewState, HomeViewAction, HomeViewEnvironment> = homeViewReducer
	
	var initialState: HomeViewState!
	
	var expectedResult: [Station] = [
		Station("S05188", name: "MODENA PIAZZA MANZONI"),
		Station("S05997", name: "MEZZOLARA")
	]
	
	var env: HomeViewEnvironment!
	
	let arrivalsExpectedResult = ArrivalsRequest.mock(Data.arrivals!)
	
	override func setUp() {
		initialState = HomeViewState(selectedStation: nil, departures: [], arrivals: [], stations: [], favouritesStations: [], train: nil, trainSections: [], origincode: nil)
		
		let stationsEnv: StationsViewEnvironment = (
			autocomplete: { _ in Effect.sync { [] } },
			saveFavourites: { _ in Effect.sync { false } },
			retrieveFavourites: { Effect.sync { self.expectedResult } }
		)
		
		let arrivalsDepartures: ArrivalsDeparturesEnvironment = (
			departures: { _ in
				Effect.sync { [] }
			},
			arrivals: { _ in
				Effect.sync { self.arrivalsExpectedResult }
			}
		)
		
		let sections: TrainSectionViewEnvironment = { _,_ in .sync { [] }
			
		}

		let arrivalsDeparturesViewEnv: ArrivalsDeparturesViewEnvironment = (
			arrivalsDepartures: arrivalsDepartures,
			sections: sections
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
			steps: Step(.send, .favourites(.stations(.favourites)), { _ in }),
			Step(.receive, .favourites(.stations(.favouritesResponse(self.expectedResult))), { state in
				state.favouritesStations = self.expectedResult
			})
		)
	}
	
	func test_arrivals_departures() {
		assert(
			initialValue: initialState,
			reducer: homeViewReducer,
			environment: env,
			steps: Step(.send, .arrivalsDepartures(.arrivalDepartures(.arrivals("station"))), { _ in }),
			
			Step(.receive, .arrivalsDepartures(.arrivalDepartures(.arrivalsResponse(arrivalsExpectedResult))), { state in
				state.arrivals = self.arrivalsExpectedResult
			})
		)
	}
	
	func test_sections_none() {
		assert(
			initialValue: initialState,
			reducer: homeViewReducer,
			environment: env,
			steps: Step(.send, .arrivalsDepartures(.arrivalDepartures(.arrivals("station"))), { _ in }),
			
			Step(.receive, .arrivalsDepartures(.arrivalDepartures(.arrivalsResponse(arrivalsExpectedResult))), { state in
				state.arrivals = self.arrivalsExpectedResult
			}),
			Step(.send, .arrivalsDepartures(.sections(.section(.none))), { state in
				
			})
		)
	}
}
