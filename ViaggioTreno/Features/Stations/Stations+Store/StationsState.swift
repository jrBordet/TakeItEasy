//
//  StationsStore.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

public struct StationsViewState: Equatable {
	public var stations: [Station]
	public var favouritesStations: [Station]
	
	public init(
		stations: [Station],
		favouritesStations: [Station]
	) {
		self.stations = stations
		self.favouritesStations = favouritesStations
	}
	
	var stationsState: StationsState {
		get { (self.stations, self.favouritesStations) }
		set { (self.stations, self.favouritesStations) = newValue }
	}
}

public enum StationsViewAction: Equatable {
	case stations(StationsAction)
}

public typealias StationsViewEnvironment = (
	autocomplete: (String) -> Effect<[Station]>,
	saveFavourites: ([Station]) -> Effect<Bool>,
	retrieveFavourites: () -> Effect<[Station]>
)

public let stationsViewReducer: Reducer<StationsViewState, StationsViewAction, StationsViewEnvironment> = combine(
	pullback(
		stationsReducer,
		value: \StationsViewState.stationsState,
		action: /StationsViewAction.stations,
		environment: { $0 }
	)
)

// MARk: - State

public typealias StationsState = (stations: [Station], favouritesStations: [Station])

// MARk: - Action

public enum StationsAction: Equatable {
	case autocomplete(String)
	case autocompleteResponse([Station])
	
	case favourites
	case favouritesResponse([Station])
	
	case addFavorite(Station)
	case updateFavouritesResponse(Bool)
	
	case removeFavourite(Station)
	
	case none
}

// MARK: - Environment

public typealias StationsEnvironment = (
	autocomplete: (String) -> Effect<[Station]>,
	saveFavourites: ([Station]) -> Effect<Bool>,
	retrieveFavourites: () -> Effect<[Station]>
)

public enum StationsError: Error, Equatable {
	case generic
}

func stationsReducer(
	state: inout StationsState,
	action: StationsAction,
	environment: StationsEnvironment
) -> [Effect<StationsAction>] {
	switch action {
	case let .autocomplete(value):
		return [
			environment.autocomplete(value).map(StationsAction.autocompleteResponse)
		]
	case let .autocompleteResponse(stations):
		state.stations = stations
		return []
	case .favourites:
		return [
			environment.retrieveFavourites().map(StationsAction.favouritesResponse)
		]
	case let .favouritesResponse(result):
		state.favouritesStations = result
		return []
	case .none:
		return []
	case let .addFavorite(station):
		guard (state.favouritesStations.filter { station ==  $0 }).isEmpty else {
			return []
		}
		
		state.stations = state.stations
			.map { $0.id == station.id ? nil : $0 }
			.compactMap { $0 }
		
		state.favouritesStations.append(station)
		return [
			environment.saveFavourites(state.favouritesStations).map { StationsAction.updateFavouritesResponse($0) }
		]
	case let .removeFavourite(station):
		guard (state.favouritesStations.filter { station ==  $0 }).isEmpty == false else {
			return []
		}
		
		state.favouritesStations = state.favouritesStations
			.map { $0.id == station.id ? nil : $0 }
			.compactMap { $0 }
		
		return [
			environment.saveFavourites(state.favouritesStations).map { StationsAction.updateFavouritesResponse($0) }
		]
	case let .updateFavouritesResponse(success):
		dump(success)
		return []
	}
}