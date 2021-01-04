//
//  FollowingTrains+Store.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import Foundation
import RxComposableArchitecture
import Networking

struct Train: Equatable {
	var number: String
	var status: String
	var originCode: String
	var from: Station
	var to: Station
	var duration: String
	
	struct Station: Equatable {
		var time: TimeInterval
		var name: String
	}
}

extension Train {
	static var sample = Self(
		number: "11824",
		status: "on time",
		originCode: "S00137",
		from: Train.Station(time: 1609577700000, name: "AOSTA"),
		to: Train.Station(time: 1609581960000, name: "IVREA"),
		duration: "1:11"
	)
}

let trainsViewReducer: Reducer<TrainsViewState, TrainsViewAction, TrainsViewEnvironment> = combine(
	pullback(
		trainsReducer,
		value: \TrainsViewState.trainsState,
		action: /TrainsViewAction.trains,
		environment: { $0 }
	)
)

struct TrainsViewState: Equatable {
	var trains: [Trend]
	var selectedTrend: Trend?
	var error: FollowingTrainsError?
	
	init(
		trains: [Trend],
		selectedTrend: Trend?,
		error: FollowingTrainsError?
	) {
		self.selectedTrend = selectedTrend
		self.trains = trains
		self.error = error
	}
	
	var trainsState: TrainsState {
		get {(
			self.trains,
			self.selectedTrend,
			self.error
		)}
		set {
			self.selectedTrend = newValue.selectedTrend
			self.trains = newValue.trains
			self.error = newValue.error
		}
	}
}

enum TrainsViewAction: Equatable {
	case trains(TrainsAction)
}

typealias TrainsViewEnvironment = (
	saveTrains: ([Trend]) -> Effect<Bool>,
	retrieveTrains: () -> Effect<[Trend]>,
	retrieveTrend: (String, String) -> Effect<Trend?>
)

// MARK: - State

public enum FollowingTrainsError: Error, Equatable {
	case generic(String)
	case notSaved
}

typealias TrainsState = (trains: [Trend], selectedTrend: Trend?, error: FollowingTrainsError?)

// MARK: - Action

enum TrainsAction: Equatable {
	case trains
	case trainsResponse([Trend])
	
	case trend(String, String) // originCode, trainNumber
	case trendResponse(Trend?)
	
	case add(Trend)
	case remove(Trend)
	
	case updateResponse(Bool)
	
	case select(Trend?)
	
	case none
}

// MARK: - Environment

typealias TrainsEnvironment = (
	saveTrains: ([Trend]) -> Effect<Bool>,
	retrieveTrains: () -> Effect<[Trend]>,
	retrieveTrend: (String, String) -> Effect<Trend?>
)

func trainsReducer(
	state: inout TrainsState,
	action: TrainsAction,
	environment: TrainsEnvironment
) -> [Effect<TrainsAction>] {
	switch action {
	case .trains:
		return [
			environment.retrieveTrains().map(TrainsAction.trainsResponse)
		]
	case let .trainsResponse(result):
		state.trains = result
		return []
	case let .add(train):
		guard (state.trains.filter { train ==  $0 }).isEmpty else {
			return []
		}
		
		state.trains.append(train)
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .updateResponse(response):
		guard response == true else {
			state.error = FollowingTrainsError.notSaved
			return []
		}
		return []
	case let .remove(train):
		guard (state.trains.filter { train ==  $0 }).isEmpty == false else {
			return []
		}
		
		state.trains = state.trains
			.map { $0.numeroTreno == train.numeroTreno ? nil : $0 }
			.compactMap { $0 }
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .select(trend):
		state.selectedTrend = trend
		return []
	case .none:
		return []
	case let .trend(origin, number):
		return [
			environment.retrieveTrend(origin, number).map(TrainsAction.trendResponse)
		]
	case let .trendResponse(trend):
		guard let trend = trend else {
			return []
		}
		
		return [
			Effect.sync { }.map { TrainsAction.add(trend) }
		]
	}
}
