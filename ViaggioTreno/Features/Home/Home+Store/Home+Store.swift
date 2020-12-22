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
	public var selectedStation: Station?
	public var departures: [Departure]
	public var arrivals: [Arrival]
	public var stations: [Station]
	public var favouritesStations: [Station]
	
	public init(
		selectedStation: Station?,
		departures: [Departure],
		arrivals: [Arrival],
		stations: [Station],
		favouritesStations: [Station]
	) {
		self.selectedStation = selectedStation
		self.departures = departures
		self.arrivals = arrivals
		self.stations = stations
		self.favouritesStations = favouritesStations
	}
	
	var favouritesStationsState: StationsViewState {
		get {
			StationsViewState(
				stations: self.stations,
				favouritesStations: self.favouritesStations,
				selectedStation: self.selectedStation
			)
			
		}
		set {
			self.stations = newValue.stations
			self.favouritesStations = newValue.favouritesStations
			self.selectedStation = newValue.selectedStation
		}
	}
	
	var arrivalsDeparturesState: ArrivalsDeparturesViewState {
		get {
			ArrivalsDeparturesViewState(
				selectedStation: self.selectedStation,
				departures: self.departures,
				arrivals: self.arrivals
			)
		}
		
		set {
			self.selectedStation = newValue.selectedStation
			self.departures = newValue.departures
			self.arrivals = newValue.arrivals
		}
	}
}

public enum HomeViewAction: Equatable {
	case favourites(StationsViewAction)
	case arrivalsDepartures(ArrivalsDeparturesViewAction)
}

public typealias HomeViewEnvironment = (
	stations: StationsEnvironment,
	arrivalsDepartures: ArrivalsDeparturesViewEnvironment
)

public let homeViewReducer: Reducer<HomeViewState, HomeViewAction, HomeViewEnvironment> = combine(
	pullback(
		stationsViewReducer,
		value: \HomeViewState.favouritesStationsState,
		action: /HomeViewAction.favourites,
		environment: { $0.stations }
	),
	pullback(
		arrivalsDeparturesViewReducer,
		value: \HomeViewState.arrivalsDeparturesState,
		action: /HomeViewAction.arrivalsDepartures,
		environment: { $0.arrivalsDepartures }
	)
)
