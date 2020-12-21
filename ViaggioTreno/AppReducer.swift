//
//  AppReducer.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation
import RxComposableArchitecture

let appReducer: Reducer<AppState, AppAction, AppEnvironment> =  combine(
	pullback(
		homeViewReducer,
		value: \AppState.stations,
		action: /AppAction.home,
		environment: { $0 }
	)
)
