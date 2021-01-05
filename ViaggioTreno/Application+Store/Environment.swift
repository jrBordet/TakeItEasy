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

let followingEnvMock: TrainsViewEnvironment = (
	saveTrains: { _ in
		Effect.sync {  true }
	},
	retrieveTrains: {
		Effect.sync { [] }
	}, retrieveTrend: { origin, train in
		Effect.sync { nil }
	}
)

let followingEnvLive: TrainsViewEnvironment = (
		saveTrains: {
			saveTrains(with: $0)
		},
		retrieveTrains: {
			retrieveTrains()
		}, retrieveTrend: { origin, train in
			TrendRequest(origin: origin, train: train)
				.execute()
				.map { $0 }
		}
	)

let sectionsEnv: TrainSectionViewEnvironment = (
	sections: { station, train in
		TrainSectionsRequest(station: station, train: train)
			.execute()
			.map { sections in
				guard sections.isEmpty == false else {
					throw APIError.noContent
				}

				return sections
			}
	},
	followingTrains: followingEnvLive
)

let arrivalsDeparturesViewEnvLive: ArrivalsDeparturesViewEnvironment = (
	arrivalsDepartures: arrivalsDeparturesEnvLive,
	sections: sectionsEnv
)

let live: AppEnvironment = (
	stations: stationsEnvLive,
	arrivalsDepartures: arrivalsDeparturesViewEnvLive,
	followingTrains: followingEnvLive
)

func saveTrains(with t: [FollowingTrain]) -> Effect<Bool> {
	TrainsFavouritesFileClient()
		.persist(with: t)
		.catchErrorJustReturn(false)
}

func retrieveTrains() -> Effect<[FollowingTrain]> {
	TrainsFavouritesFileClient()
		.fetch()
		.catchErrorJustReturn([])
}

func saveTrend(with t: [Trend]) -> Effect<Bool> {
	TrendFileClient()
		.persist(with: t)
		.catchErrorJustReturn(false)
}

func retrieveTrend() -> Effect<[Trend]> {
	TrendFileClient()
		.fetch()
		.catchErrorJustReturn([])
}

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
