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
	  stationsViewReducer,
	  value: \AppState.stations,
	  action: /AppAction.stations,
	  environment: { $0 }
	  )
)
