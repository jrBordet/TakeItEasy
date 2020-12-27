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
				origincode: self.originCode
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
		}
	}
}

let initialAppState = AppState(
	departures: [],
	arrivals: [],
	stations: [],
	favouritesStations: [],
	trainSections: []
)

func activityFeed(
	_ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
	return { state, action, environment in
		
		switch action {
		case let .stations(stationsAction):
			switch stationsAction {
			case let .stations(stations):
				switch stations {
				case let .autocomplete(value):
					os_log("autocomplete %{public}@ ", log: OSLog.login, type: .info, [action, value])
					break
				case let .autocompleteResponse(value):
					os_log("autocompleteResponse %{public}@ ", log: OSLog.login, type: .info, [action, value])
					break
				case .favourites:
					break
				case .favouritesResponse(_):
					break
				case .addFavorite(_):
					break
				case .updateFavouritesResponse(_):
					break
				case .removeFavourite(_):
					break
				case .select(_):
					break
				case .none:
					break
				}
				break
			}
			break
		case let .home(homeAction):
			switch homeAction {
			case let .favourites(favouritesAction):
				switch favouritesAction {
				case let .stations(stationsAction):
					switch stationsAction {
					case let .autocomplete(value):
						os_log("autocomplete %{public}@ ", log: OSLog.login, type: .info, [action, value])
						break
					case let .autocompleteResponse(value):
						os_log("autocompleteResponse %{public}@ ", log: OSLog.login, type: .info, [action, value])
					case .favourites:
						break
					case .favouritesResponse(_):
						break
					case .addFavorite(_):
						break
					case .updateFavouritesResponse(_):
						break
					case .removeFavourite(_):
						break
					case .select(_):
						break
					case .none:
						break
					}
					break
				}
				break
			case .arrivalsDepartures(_):
				break
			}
			break
		}
		
		//        if case let .counter(.counter(counterAction)) = action {
		//            switch counterAction {
		//            case .incrTapped:
		//                os_log("incrTapped %{public}@ ", log: OSLog.counter, type: .info, [state])
		//                break
		//            case .decrTapped:
		//                break
		//            case .nthPrimeButtonTapped:
		//                break
		//            case .nthPrimeResponse(_):
		//                break
		//            case .alertDismissButtonTapped:
		//                break
		//            }
		//        }
		//
		//        if case let .login(.login(loginAction)) = action {
		//            os_log("login %{public}@ ", log: OSLog.login, type: .info, [action, state])
		//
		//            switch loginAction {
		//            case .username(_):
		//                break
		//            case .password(_):
		//                break
		//            case .login:
		//                break
		//            case .loginResponse(_):
		//                break
		//            case .checkRememberMeStatus:
		//                break
		//            case .checkRememberMeStatusResponse(_, _):
		//                break
		//            case .rememberMe:
		//                break
		//            case .rememberMeResponse(_):
		//                break
		//            case .dismissAlert:
		//                break
		//            case .retrieveCredentials:
		//                break
		//            case .retrieveCredentialsResponse(_, _):
		//                break
		//            case .none:
		//                break
		//            }
		//        }
		
		return reducer(&state, action, environment)
	}
}

extension OSLog {
	private static var subsystem = Bundle.main.bundleIdentifier!
	
	static let board = OSLog(subsystem: subsystem, category: "Stations board")
	
	static let counter = OSLog(subsystem: subsystem, category: "Counter")
	static let login = OSLog(subsystem: subsystem, category: "Login")
}
