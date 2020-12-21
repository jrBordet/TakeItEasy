//
//  Home+Store.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 21/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

public struct HomeViewState: Equatable {
	public var favouritesStations: StationsViewState
	
	public init(
		favouritesStations: StationsViewState
	) {
		self.favouritesStations = favouritesStations
	}
	
	var favouritesStationsState: StationsViewState {
		get { self.favouritesStations }
		set { self.favouritesStations = newValue }
	}
}

public enum HomeViewAction: Equatable {
	case favourites(StationsViewAction)
}

public typealias HomeViewEnvironment = (
	autocomplete: (String) -> Effect<[Station]>,
	saveFavourites: ([Station]) -> Effect<Bool>,
	retrieveFavourites: () -> Effect<[Station]>
)

public let homeViewReducer: Reducer<HomeViewState, HomeViewAction, HomeViewEnvironment> = combine(
	pullback(
		stationsViewReducer,
		value: \HomeViewState.favouritesStationsState,
		action: /HomeViewAction.favourites,
		environment: { $0 }
	)
)
