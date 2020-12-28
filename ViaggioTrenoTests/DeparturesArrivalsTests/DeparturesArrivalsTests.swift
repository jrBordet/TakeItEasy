//
//  DeparturesArrivalsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 28/12/2020.
//

import XCTest
@testable import ViaggioTreno
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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		initialState = ArrivalsDeparturesViewState(
			selectedStation: nil,
			departures: [],
			arrivals: [],
			train: nil,
			trainSections: [],
			originCode: nil
		)
		
		env = (
			arrivalsDepartures: (
				departures: { _ in Effect.sync { self.expectedResult } },
				arrivals: { _ in Effect.sync { [] } }
			),
			sections: { _, _ in Effect.sync { [] } }
		)
		
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_retreive_departures() throws {
		assert(
			initialValue: initialState,
			reducer: reducer,
			environment: env,
			steps: Step(.send, .arrivalDepartures(.departures("mock_departures")), { state in
				
			}),
			Step(.receive, .arrivalDepartures(.departuresResponse(expectedResult)), { state in
				state.departures = self.expectedResult
			})
		)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
