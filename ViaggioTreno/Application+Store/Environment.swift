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
		DeparturesRequest(code: station, date: Date())
			.execute()
			.map { sections in
				guard sections.isEmpty == false else {
					throw APIError.noContent
				}
				
				return sections
			}
	},
	arrivals: { id in
		ArrivalsRequest(code: id, date: Date())
			.execute()
			.map { sections in
				guard sections.isEmpty == false else {
					throw APIError.noContent
				}
				
				return sections
			}
	}
)

let arrivalsDeparturesViewEnvLive: ArrivalsDeparturesViewEnvironment = (
	arrivalsDepartures: arrivalsDeparturesEnvLive,
	sections: { station, train in
		TrainSectionsRequest(station: station, train: train)
			.execute()
			.map { sections in
				guard sections.isEmpty == false else {
					throw APIError.noContent
				}
				
				return sections
			}
	}
)

let live: AppEnvironment = (
	stations: stationsEnvLive,
	arrivalsDepartures: arrivalsDeparturesViewEnvLive
)

func saveFavourites(stations s: [Station]) -> Effect<Bool> {
	FavouritesFileClient()
		.persist(with: s)
		.catchErrorJustReturn(false)
}

func retrieveFavourites() -> Effect<[Station]> {
	FavouritesFileClient()
		.fetch()
		.catchErrorJustReturn([])
}
