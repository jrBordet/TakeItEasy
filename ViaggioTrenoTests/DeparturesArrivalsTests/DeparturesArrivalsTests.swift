//
//  DeparturesArrivalsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 28/12/2020.
//

import XCTest
@testable import PendolareStanco
import RxComposableArchitectureTests
import Difference
import RxComposableArchitecture
import RxSwift
import RxCocoa
import Networking

class DeparturesArrivalsTests: XCTestCase {	
	let reducer: Reducer<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction, ArrivalsDeparturesViewEnvironment> = arrivalsDeparturesViewReducer
	
	var env: ArrivalsDeparturesViewEnvironment!
	
	var initialState: ArrivalsDeparturesViewState!
	
	var expectedResult = DeparturesRequest.mock(Data.departures!)
	let arrivalsExpectedResult = ArrivalsRequest.mock(Data.arrivals!)
	var sectionsExpectedResult: [TrainSection] = TrainSectionsRequest.mock(Data.train_sections!)
	
	var selectedStationExpectedResult = Station.milano.first!
	var currentTrain = CurrentTrain(number: "S0129", name: "Milano", status: "in orario", originCode: "S1245")
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		
		initialState = ArrivalsDeparturesViewState(
			selectedStation: nil,
			departures: [],
			arrivals: [],
			train: nil,
			trainSections: [],
			originCode: nil,
			isRefreshing: false,
			followingTrainsState: TrainsViewState(
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
					false
				}
			},
			retrieveTrains: {
				Effect.sync {
					[]
				}
			},
			retrieveTrend: { _, _ in
				Effect.sync { nil }
			}
		)
		
		let sectionsEnv: TrainSectionViewEnvironment = (
			sections: { _, _ in Effect.sync { self.sectionsExpectedResult } },
			followingTrains: followingEnvMock
		)
		
		env = (
			arrivalsDepartures: (
				departures: { _ in Effect.sync { self.expectedResult } },
				arrivals: { _ in Effect.sync { self.arrivalsExpectedResult } }
			),
			sections: sectionsEnv
		)
		
	}
	
	// MARK: - TESTS
	
	func test_retrieve_departures() throws {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .arrivalDepartures(.departures("station")), { state in
				
			}),
			Step(.receive, .arrivalDepartures(.departuresResponse(expectedResult)), { state in
				state.departures = self.expectedResult
			})
		)
	}
	
	func test_retrieve_arrivals() throws {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .arrivalDepartures(.arrivals("station")), { state in
				
			}),
			Step(.receive, .arrivalDepartures(.arrivalsResponse(arrivalsExpectedResult)), { state in
				state.arrivals = self.arrivalsExpectedResult
			})
		)
	}
	
	func test_select_station() throws {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .arrivalDepartures(.select(selectedStationExpectedResult)), { state in
				state.selectedStation = self.selectedStationExpectedResult
			})
		)
	}
	
	func test_select_train() throws {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .arrivalDepartures(.selectTrain(currentTrain)), { state in
				state.train = self.currentTrain
			})
		)
	}
	
	func test_retrieve_sections() throws {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .sections(.section(.trainSections("originCode", "station"))), { state in
				
			}),
			Step(.receive, .sections(.section(.trainSectionsResponse(self.sectionsExpectedResult))), { state in
				state.trainSections = self.sectionsExpectedResult
			})
		)
	}
}
