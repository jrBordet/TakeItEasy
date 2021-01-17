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
	var originCode: String?
	var isRefreshing: Bool
	
	var followingTrainsState: TrainsViewState
	
	init(
		selectedStation: Station?,
		departures: [Departure],
		arrivals: [Arrival],
		stations: [Station],
		favouritesStations: [Station],
		train: CurrentTrain?,
		trainSections: [TrainSection],
		origincode: String?,
		isRefreshing: Bool,
		followingTrainsState: TrainsViewState
	) {
		self.selectedStation = selectedStation
		self.departures = departures
		self.arrivals = arrivals
		self.stations = stations
		self.favouritesStations = favouritesStations
		self.train = train
		self.trainSections = trainSections
		self.originCode = origincode
		self.isRefreshing = isRefreshing
		self.followingTrainsState = followingTrainsState
	}
	
	// MARK: View states
	
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
				trainSections: self.trainSections,
				originCode: self.originCode,
				isRefreshing: self.isRefreshing,
				followingTrainsState: self.followingTrainsState
			)
		}
		
		set {
			self.selectedStation = newValue.selectedStation
			self.departures = newValue.departures
			self.arrivals = newValue.arrivals
			self.train = newValue.train
			self.trainSections = newValue.trainSections
			self.originCode = newValue.originCode
			self.isRefreshing = newValue.isRefreshing
			self.followingTrainsState = newValue.followingTrainsState
		}
	}
	
	var followingTrainsViewState: TrainsViewState {
		get {
			self.followingTrainsState
		}
		
		set {
			self.followingTrainsState = TrainsViewState(
				trains: newValue.trains,
				trends: newValue.trends,
				selectedTrend: newValue.selectedTrend,
				error: newValue.error,
				selectedTrain: FollowingTrain(
					originCode: self.train?.originCode ?? "",
					trainNumber: self.train?.number ?? ""
				),
				isFollowing: newValue.isFollowing
			)
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

enum HomeViewAction: Equatable {
	case favourites(StationsViewAction)
	case arrivalsDepartures(ArrivalsDeparturesViewAction)
	case following(TrainsViewAction)
	case sections(TrainSectionViewAction)
}

typealias HomeViewEnvironment = (
	stations: StationsEnvironment,
	arrivalsDepartures: ArrivalsDeparturesViewEnvironment,
	followingTrains: TrainsViewEnvironment
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
	),
	pullback(
		trainsViewReducer,
		value: \HomeViewState.followingTrainsViewState,
		action: /HomeViewAction.following,
		environment: { $0.followingTrains }
	),
	pullback(
		trainSectionViewReducer,
		value: \HomeViewState.trainSectionsViewState,
		action: /HomeViewAction.sections,
		environment: { $0.arrivalsDepartures.sections }
	)
)
