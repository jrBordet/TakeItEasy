//
//  TrainSection+Store.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 22/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

let trainSectionViewReducer: Reducer<TrainSectionViewState, TrainSectionViewAction, TrainSectionViewEnvironment> = combine(
	pullback(
		trainSectionReducer,
		value: \TrainSectionViewState.sectionState,
		action: /TrainSectionViewAction.section,
		environment: { $0 }
	)
)

struct TrainSectionViewState: Equatable {
	var selectedStation: Station?
	var train: CurrentTrain?
	var trainSections: [TrainSection]
	var originCode: String?
	var isRefreshing: Bool
	
	init(
		selectedStation: Station?,
		train: CurrentTrain?,
		trainSections: [TrainSection],
		originCode: String?,
		isRefreshing: Bool
	) {
		self.selectedStation = selectedStation
		self.train = train
		self.trainSections = trainSections
		self.originCode = originCode
		self.isRefreshing = isRefreshing
	}
	
	var sectionState: TrainSectionState {
		get {(
			self.selectedStation,
			self.originCode,
			self.train,
			self.trainSections,
			self.isRefreshing
		)}
		set {
			self.selectedStation = newValue.selectedStation
			self.train = newValue.train
			self.trainSections = newValue.trainSections
			self.originCode = newValue.originCode
			self.isRefreshing = newValue.isRefreshing
		}
	}
}

enum TrainSectionViewAction: Equatable {
	case section(TrainSectionAction)
}

typealias TrainSectionViewEnvironment = (String, String) -> Effect<[TrainSection]>

// MARk: - State

typealias TrainSectionState = (selectedStation: Station?, originCode: String?, train: CurrentTrain?, trainSections: [TrainSection], isRefreshing: Bool)

// MARk: - Action

enum TrainSectionAction: Equatable {
	case trainSections(String, String)
	case trainSectionsResponse([TrainSection])
	
	case select(Station?)
	case selectTrain(CurrentTrain?)
	
	case refresh(String, String)
	
	case none
}

// MARK: - Environment

typealias TrainSectionEnvironment = (_ originCode: String, _ train: String) -> Effect<[TrainSection]>

func trainSectionReducer(
	state: inout TrainSectionState,
	action: TrainSectionAction,
	environment: TrainSectionEnvironment
) -> [Effect<TrainSectionAction>] {
	switch action {
	case let .trainSections(originCode, train):
		return [
			environment(originCode, train).map(TrainSectionAction.trainSectionsResponse)
		]
	case let .trainSectionsResponse(trainSections):
		state.trainSections = trainSections
		state.isRefreshing = false
		return []
	case .none:
		return []
	case let .select(station):
		state.selectedStation = station
		return [
		]
	case let .selectTrain(value):
		state.train = value
		return []
	case let .refresh(originCode, train):
		state.isRefreshing = true
		
		return [
			environment(originCode, train).map(TrainSectionAction.trainSectionsResponse)
		]
	}
}
