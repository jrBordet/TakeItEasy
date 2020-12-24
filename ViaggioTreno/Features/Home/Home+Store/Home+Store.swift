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
	var selectedStation: Station?
	var departures: [Departure]
	var arrivals: [Arrival]
	var stations: [Station]
	var favouritesStations: [Station]
	var train: CurrentTrain?
	var trainSections: [TrainSection]
	
	init(
		selectedStation: Station?,
		departures: [Departure],
		arrivals: [Arrival],
		stations: [Station],
		favouritesStations: [Station],
		train: CurrentTrain?,
		trainSections: [TrainSection]
	) {
		self.selectedStation = selectedStation
		self.departures = departures
		self.arrivals = arrivals
		self.stations = stations
		self.favouritesStations = favouritesStations
		self.train = train
		self.trainSections = trainSections
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
				arrivals: self.arrivals,
				train: self.train,
				trainSections: self.trainSections
			)
		}
		
		set {
			self.selectedStation = newValue.selectedStation
			self.departures = newValue.departures
			self.arrivals = newValue.arrivals
			self.train = newValue.train
			self.trainSections = newValue.trainSections
		}
	}
}

enum HomeViewAction: Equatable {
	case favourites(StationsViewAction)
	case arrivalsDepartures(ArrivalsDeparturesViewAction)
}

typealias HomeViewEnvironment = (
	stations: StationsEnvironment,
	arrivalsDepartures: ArrivalsDeparturesViewEnvironment
)

let homeViewReducer: Reducer<HomeViewState, HomeViewAction, HomeViewEnvironment> = combine(
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
