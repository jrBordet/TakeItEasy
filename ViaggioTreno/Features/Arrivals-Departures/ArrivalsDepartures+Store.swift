//
//  ArrivalsDepartures+Store.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 21/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

public struct ArrivalsDeparturesViewState: Equatable {
	public var selectedStation: Station?
	public var departures: [Departure]
	public var arrivals: [Arrival]
	
	public init(
		selectedStation: Station?,
		departures: [Departure],
		arrivals: [Arrival]
	) {
		self.selectedStation = selectedStation
		self.departures = departures
		self.arrivals = arrivals
	}
	
	var stationsState: ArrivalsDeparturesState {
		get { (self.selectedStation, self.departures, self.arrivals) }
		set { (self.selectedStation, self.departures, self.arrivals) = newValue }
	}
}

public enum ArrivalsDeparturesViewAction: Equatable {
	case arrivalDepartures(ArrivalsDeparturesAction)
}

public typealias ArrivalsDeparturesViewEnvironment = (
	departures: (String) -> Effect<[Departure]>,
	arrivals: (String) -> Effect<[Arrival]>
)

public let arrivalsDeparturesViewReducer: Reducer<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction, ArrivalsDeparturesViewEnvironment> = combine(
	pullback(
		arrivalsDeparturesReducer,
		value: \ArrivalsDeparturesViewState.stationsState,
		action: /ArrivalsDeparturesViewAction.arrivalDepartures,
		environment: { $0 }
	)
)

// MARk: - State

public typealias ArrivalsDeparturesState = (selectedStation: Station?, departures: [Departure], arrivals: [Arrival])

// MARk: - Action

public enum ArrivalsDeparturesAction: Equatable {
	case departures(String)
	case departuresResponse([Departure])
	
	case arrivals(String)
	case arrivalsResponse([Arrival])
	
	case select(Station?)
		
	case none
}

// MARK: - Environment

public typealias ArrivalsDeparturesEnvironment = (
	departures: (String) -> Effect<[Departure]>,
	arrivals: (String) -> Effect<[Arrival]>
)

func arrivalsDeparturesReducer(
	state: inout ArrivalsDeparturesState,
	action: ArrivalsDeparturesAction,
	environment: ArrivalsDeparturesEnvironment
) -> [Effect<ArrivalsDeparturesAction>] {
	switch action {
	case let .departures(value):
		return [
			environment.departures(value).map(ArrivalsDeparturesAction.departuresResponse)
		]
	case let .departuresResponse(departures):
		state.departures = departures
		return []
	case let .arrivals(value):
		return [
			environment.arrivals(value).map(ArrivalsDeparturesAction.arrivalsResponse)
		]
	case let .arrivalsResponse(result):
		state.arrivals = result
		return []
	case .none:
		return []
	case let .select(station):
		state.selectedStation = station
		return [
			
		]
	}
}
