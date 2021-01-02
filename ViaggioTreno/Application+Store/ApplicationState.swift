//
//  AppState.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 22/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import Foundation
import RxComposableArchitecture
import os.log
import Networking

public struct AppState {
	var selectedStation: Station?
	var departures: [Departure]
	var arrivals: [Arrival]
	var stations: [Station]
	var favouritesStations: [Station]
	var trainSections: [TrainSection]
	var train: CurrentTrain?
	var originCode: String?
	var isRefreshing: Bool
	
	var followingTrainsState: TrainsViewState
}

extension AppState {
	var homeState: HomeViewState {
		get {
			HomeViewState(
				selectedStation: self.selectedStation,
				departures: self.departures,
				arrivals: self.arrivals,
				stations: self.stations,
				favouritesStations: self.favouritesStations,
				train: self.train,
				trainSections: self.trainSections,
				origincode: self.originCode,
				isRefreshing: self.isRefreshing,
				followingTrainsState: self.followingTrainsState
			)
		}
		set {
			self.selectedStation = newValue.selectedStation
			self.departures = newValue.departures
			self.arrivals = newValue.arrivals
			self.stations = newValue.stations
			self.favouritesStations = newValue.favouritesStations
			self.trainSections = newValue.trainSections
			self.train = newValue.train
			self.originCode = newValue.originCode
			self.isRefreshing = newValue.isRefreshing
		}
	}
}

let initialAppState = AppState(
	departures: [],
	arrivals: [],
	stations: [],
	favouritesStations: [],
	trainSections: [],
	isRefreshing: false,
	followingTrainsState: TrainsViewState(
		trains: [],
		selectedTrain: nil,
		error: nil
	)
)
