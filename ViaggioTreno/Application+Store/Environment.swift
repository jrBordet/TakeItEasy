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

typealias AppEnvironment = HomeViewEnvironment

let stationsEnvLive: StationsViewEnvironment = (
	autocomplete: { StationsRequest.autocompleteStation(with: $0)},
	saveFavourites: { saveFavourites(stations: $0) } ,
	retrieveFavourites: { retrieveFavourites() }
)

//typealias ArrivalsDeparturesViewEnvironment = (
//	arrivalsDepartures: ArrivalsDeparturesEnvironment,
//	sections: TrainSectionViewEnvironment
//)

let arrivalsDeparturesEnvLive: ArrivalsDeparturesEnvironment = (
	departures: { id in
		DeparturesRequest
			.fetch(from: id)
			.debug("[DeparturesRequest]", trimOutput: false)
	},
	arrivals: { id in
		ArrivalsRequest
			.fetch(from: id)
			.debug("[ArrivalsRequest]", trimOutput: false)
	}
)

let sections = TrainSectionsRequest.fetch(from: "", train: "")

let arrivalsDeparturesViewEnvLive: ArrivalsDeparturesViewEnvironment = (
	arrivalsDepartures: arrivalsDeparturesEnvLive,
	sections: { train, station in
		TrainSectionsRequest.fetch(from: station, train: train)
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