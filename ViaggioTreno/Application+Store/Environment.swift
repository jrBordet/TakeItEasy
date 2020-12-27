//
//  Environment.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation
import RxComposableArchitecture
import Networking
import FileClient
import os.log
import RxSwift

typealias AppEnvironment = HomeViewEnvironment

extension OSLog {
	private static var subsystem = Bundle.main.bundleIdentifier!
	
	static let networking = OSLog(subsystem: subsystem, category: "Networking")
}

let stationsEnvLive: StationsViewEnvironment = (
	autocomplete: {
		StationsRequest(station: $0).execute(parse: {
			$0.parseStations()
		})
	},
	saveFavourites: { saveFavourites(stations: $0) } ,
	retrieveFavourites: { retrieveFavourites() }
)

let arrivalsDeparturesEnvLive: ArrivalsDeparturesEnvironment = (
	departures: { station in
		DeparturesRequest(code: station, date: Date()).execute()
	},
	arrivals: { id in
		ArrivalsRequest(code: id, date: Date()).execute()
	}
)

let sections = TrainSectionsRequest.fetch(from: "", train: "")

let arrivalsDeparturesViewEnvLive: ArrivalsDeparturesViewEnvironment = (
	arrivalsDepartures: arrivalsDeparturesEnvLive,
	sections: { station, train in
		TrainSectionsRequest(station: station, train: train).execute()
	}
)

let live: AppEnvironment = (
	stations: stationsEnvLive,
	arrivalsDepartures: arrivalsDeparturesViewEnvLive
)

func saveFavourites(stations s: [Station]) -> Effect<Bool> {
	.sync { () -> Bool in
		switch FavouritesFileClient().persist(s) {
		case let .success(v):
			return v
		case .failure:
			return false
		}
	}
}

func retrieveFavourites() -> Effect<[Station]> {
	.sync { () -> [Station] in
		switch FavouritesFileClient().retrieve() {
		case let .success(stations):
			return stations
		case .failure(_):
			return []
		}
	}
}
