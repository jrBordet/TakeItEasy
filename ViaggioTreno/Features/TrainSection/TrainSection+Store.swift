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
	var trainNumber: Int?
	var trainSections: [TrainSection]
	
	init(
		selectedStation: Station?,
		trainNumber: Int?,
		trainSections: [TrainSection]
	) {
		self.selectedStation = selectedStation
		self.trainNumber = trainNumber
		self.trainSections = trainSections
	}
	
	var sectionState: TrainSectionState {
		get { (self.selectedStation,  self.trainNumber, self.trainSections) }
		set {
			self.selectedStation = newValue.selectedStation
			self.trainNumber = newValue.trainNumber
			self.trainSections = newValue.trainSections
		}
	}
}

enum TrainSectionViewAction: Equatable {
	case section(TrainSectionAction)
}

typealias TrainSectionViewEnvironment = (String, String) -> Effect<[TrainSection]>

// MARk: - State

typealias TrainSectionState = (selectedStation: Station?, trainNumber: Int?, trainSections: [TrainSection])

// MARk: - Action

enum TrainSectionAction: Equatable {
	case trainSections(String, String)
	case trainSectionsResponse([TrainSection])
	
	case select(Station?)
	case selectTrain(Int?)
	
	case none
}

// MARK: - Environment

typealias TrainSectionEnvironment = (_ station: String, _ train: String) -> Effect<[TrainSection]>

func trainSectionReducer(
	state: inout TrainSectionState,
	action: TrainSectionAction,
	environment: TrainSectionEnvironment
) -> [Effect<TrainSectionAction>] {
	switch action {
	case let .trainSections(station, train):
		return [
			environment(station, train).map(TrainSectionAction.trainSectionsResponse)
		]
	case let .trainSectionsResponse(trainSections):
		state.trainSections = trainSections
		return []
	case .none:
		return []
	case let .select(station):
		state.selectedStation = station
		return [
			
		]
	case let .selectTrain(value):
		state.trainNumber = value
		return []
	}
}
