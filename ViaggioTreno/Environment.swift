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

public typealias AppEnvironment = StationsViewEnvironment

let stationsEnvLive: StationsViewEnvironment = (
	autocomplete: { StationsRequest.autocompleteStation(with: $0)},
	saveFavourites: { saveFavourites(stations: $0) } ,
	retrieveFavourites: { retrieveFavourites() }
)

let arrivalsDeparturesViewEnvLive: ArrivalsDeparturesViewEnvironment = (
	departures: { _ in
		Effect.sync {
			[]
		}
	},
	arrivals: { id in
		ArrivalsRequest.fetch(from: id, date: Date()).debug("[TEST]", trimOutput: false)
	}
)

let live: AppEnvironment = stationsEnvLive

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
