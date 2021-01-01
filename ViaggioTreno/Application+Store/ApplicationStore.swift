//
//  AppStore.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation
import RxComposableArchitecture
import SwiftPrettyPrint

var applicationStore: Store<AppState, AppAction> =
  Store(
    initialValue: initialAppState,
    reducer: with(
      appReducer,
      compose(
		customLogging,
        activityFeed
    )),
    environment: live
)


public func customLogging<Value, Action, Environment>(
	_ reducer: @escaping Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
	return { value, action, environment in
		let effects = reducer(&value, action, environment)
		let _value = value
		return [.fireAndForget {
			
			Pretty.prettyPrint(Date())
			Pretty.prettyPrint(_value)

			print("\n---\n")
			}] + effects
	}
}
