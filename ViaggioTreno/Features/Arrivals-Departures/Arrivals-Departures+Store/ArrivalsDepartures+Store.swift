//
//  ArrivalsDepartures+Store.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 21/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

struct ArrivalsDeparturesViewState: Equatable {
	var selectedStation: Station?
	var departures: [Departure]
	var arrivals: [Arrival]
	var train: CurrentTrain?
	var trainSections: [TrainSection]
	var originCode: String?
	var isRefreshing: Bool
		
	var followingTrainsState: TrainsViewState
	
	init(
		selectedStation: Station?,
		departures: [Departure],
		arrivals: [Arrival],
		train: CurrentTrain?,
		trainSections: [TrainSection],
		originCode: String?,
		isRefreshing: Bool,
		followingTrainsState: TrainsViewState
	) {
		self.selectedStation = selectedStation
		self.departures = departures
		self.arrivals = arrivals
		self.train = train
		self.trainSections = trainSections
		self.originCode = originCode
		self.isRefreshing = isRefreshing
		self.followingTrainsState = followingTrainsState
	}
	
	var stationsViewState: ArrivalsDeparturesState {
		get { (
			self.selectedStation,
			self.departures,
			self.arrivals,
			self.train,
			self.isRefreshing
		) }
		set {
			self.selectedStation = newValue.selectedStation
			self.departures = newValue.departures
			self.arrivals = newValue.arrivals
			self.train = newValue.train
			self.isRefreshing = newValue.isRefreshing
		 }
	}
	
	var trainSectionsViewState: TrainSectionViewState {
		get {
			TrainSectionViewState(
				selectedStation: self.selectedStation,
				train: self.train,
				trainSections: self.trainSections,
				originCode: self.train?.originCode,
				isRefreshing: self.isRefreshing,
				followingTrainsState: self.followingTrainsState
			)
		}
		
		set {
			self.selectedStation = newValue.selectedStation
			self.train = newValue.train
			self.trainSections = newValue.trainSections
			self.originCode = newValue.train?.originCode
			self.isRefreshing = newValue.isRefreshing
			self.followingTrainsState = newValue.followingTrainsState
		}
	}
}

enum ArrivalsDeparturesViewAction: Equatable {
	case arrivalDepartures(ArrivalsDeparturesAction)
	case sections(TrainSectionViewAction)
}

typealias ArrivalsDeparturesViewEnvironment = (
	arrivalsDepartures: ArrivalsDeparturesEnvironment,
	sections: TrainSectionViewEnvironment
)

let arrivalsDeparturesViewReducer: Reducer<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction, ArrivalsDeparturesViewEnvironment> = combine(
	pullback(
		arrivalsDeparturesReducer,
		value: \ArrivalsDeparturesViewState.stationsViewState,
		action: /ArrivalsDeparturesViewAction.arrivalDepartures,
		environment: { $0.arrivalsDepartures }
	),
	pullback(
		trainSectionViewReducer,
		value: \ArrivalsDeparturesViewState.trainSectionsViewState,
		action: /ArrivalsDeparturesViewAction.sections,
		environment: { $0.sections }
	)
)

// MARk: - State

typealias ArrivalsDeparturesState = (selectedStation: Station?, departures: [Departure], arrivals: [Arrival], train: CurrentTrain?, isRefreshing: Bool)

// MARk: - Action

enum ArrivalsDeparturesAction: Equatable {
	case departures(String)
	case departuresResponse([Departure])
	
	case arrivals(String)
	case arrivalsResponse([Arrival])
	
	case select(Station?)
	
	case selectTrain(CurrentTrain?)
	
	case refresh
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
		state.isRefreshing = false

		state.departures = departures
		return []
	case let .arrivals(value):
		return [
			environment.arrivals(value).map(ArrivalsDeparturesAction.arrivalsResponse)
		]
	case let .arrivalsResponse(result):
		state.isRefreshing = false

		state.arrivals = result
		return []
	case .refresh:
		guard let station = state.selectedStation else {
			return []
		}
		
		state.isRefreshing = true
		
		return [
			Effect.sync {}.map { ArrivalsDeparturesAction.departures(station.id) },
			Effect.sync {}.map { ArrivalsDeparturesAction.arrivals(station.id) }

		]
	case let .select(station):
		state.selectedStation = station
		return []
	case let .selectTrain(value):
		state.train = value
		return []
	}
}
