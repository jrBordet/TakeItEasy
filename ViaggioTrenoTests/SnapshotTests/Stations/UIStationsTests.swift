//
//  UIStationsTests.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import XCTest
@testable import ViaggioTreno
import SnapshotTesting
import SceneBuilder
import RxComposableArchitecture
import Networking

class UIStationsTests: XCTestCase {
	var stationsEnv: StationsViewEnvironment!
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		stationsEnv = (
			autocomplete: { string in
				.sync {
					[]
				}
			},
			saveFavourites: { _ in .sync { true } } ,
			retrieveFavourites: { .sync { Station.milano }}
		)
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_stations_favourites_and_result() throws {
		let vc = Factory.stations
		
		vc.store = Store<StationsViewState, StationsViewAction>(
			initialValue: StationsViewState(stations:[], favouritesStations: []),
			reducer: stationsViewReducer,
			environment: stationsEnv
		)
		
		assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
		assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
	}
	
}
