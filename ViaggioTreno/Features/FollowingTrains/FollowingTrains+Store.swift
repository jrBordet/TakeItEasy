//
//  FollowingTrains+Store.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import Foundation
import RxComposableArchitecture
import Networking
import Caprice

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
	var trains: [FollowingTrain]
	var trends: [Trend]
	var selectedTrend: Trend?
	var error: FollowingTrainsError?
	var selectedTrain: FollowingTrain?
	
	init(
		trains: [FollowingTrain],
		trends: [Trend],
		selectedTrend: Trend?,
		error: FollowingTrainsError?,
		selectedTrain: FollowingTrain?
	) {
		self.trains = trains
		self.selectedTrend = selectedTrend
		self.trends = trends
		self.error = error
		self.selectedTrain = selectedTrain
	}
	
	var trainsState: TrainsState {
		get {(
			self.trains,
			self.trends,
			self.selectedTrend,
			self.error,
			self.selectedTrain
		)}
		set {
			self.trains = newValue.trains
			self.selectedTrend = newValue.selectedTrend
			self.trends = newValue.trends
			self.error = newValue.error
			self.selectedTrain = newValue.selectedTrain
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

typealias TrainsState = (trains: [FollowingTrain], trends: [Trend], selectedTrend: Trend?, error: FollowingTrainsError?, selectedTrain: FollowingTrain?)

struct FollowingTrain: Equatable {
	var originCode: String
	var trainNumber: String
	var isFollowing: Bool = false
}

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
	
	//case selectTrain(SelectedTrain?)
	
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
//	case let .selectTrain(t):
//		state.selectedTrain = t
//		return []
	case .trains:
		return [
			environment.retrieveTrains().map(TrainsAction.trainsResponse)
		]
	case let .trainsResponse(result):
		state.trends = result
		
		guard let train = state.selectedTrain else {
			return []
		}
		        
		if result.filter({ trend -> Bool in
			trend.idOrigine == train.originCode && String(trend.numeroTreno) == train.trainNumber
		}).count > 0 {
			state.selectedTrain?.isFollowing = true
		}
		
		return []
	case let .add(train):
		guard (state.trends.filter { train ==  $0 }).isEmpty else {
			return []
		}
		
		state.selectedTrain = FollowingTrain(originCode: train.idOrigine, trainNumber: String(train.numeroTreno), isFollowing: true)
		
		state.trends.append(train)
		
		return [
			environment.saveTrains(state.trends).map(TrainsAction.updateResponse)
		]
	case let .updateResponse(response):
		guard response == true else {
			state.error = FollowingTrainsError.notSaved
			return []
		}
		return []
	case let .remove(train):
		guard (state.trends.filter { train ==  $0 }).isEmpty == false else {
			return []
		}
		
		state.trends = state.trends
			.map { $0.numeroTreno == train.numeroTreno ? nil : $0 }
			.compactMap { $0 }
		
		return [
			environment.saveTrains(state.trends).map(TrainsAction.updateResponse)
		]
	case let .select(trend):
		state.selectedTrend = trend
		return []
	case .none:
		return []
	case let .trend(origin, number):
		state.selectedTrain = FollowingTrain(originCode: origin, trainNumber: number, isFollowing: false)
		
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
