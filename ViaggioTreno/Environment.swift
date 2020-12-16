//
//  Environment.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

public typealias AppEnvironment = (
	counter: CounterViewEnvironment,
	login: LoginViewEnvironment,
	stations: StationsViewEnvironment
)

let counterEnv: CounterViewEnvironment = (
	counter: { _ in .sync { 5 } },
	other: { .sync { true } }
)

let envLoginSuccess: (String, String) -> Effect<Result<String, LoginError>> =  {  _,_ in .sync { .success("login success") } }
let envLoginFailureGeneric: (String, String) -> Effect<Result<String, LoginError>> =  {  _,_ in .sync { .failure(.generic) } }
let envLoginFailureCredentials: (String, String) -> Effect<Result<String, LoginError>> =  {  _,_ in .sync { .failure(.invalidCredentials("invalid credentials")) } }

let loginEnv: LoginViewEnvironment = (
	login: envLoginFailureCredentials,
	saveCredentials: { _,_ in  .sync { true } },
	retrieveCredentials: { usename in .sync { ("fake@email.com", "Aa123123") } },
	ereaseCredentials: { username in .sync { true } }
)

let stationsEnv: StationsViewEnvironment = (
	autocomplete: { string in
		StationsRequest.autocompleteStation(with: string)
//		.sync {
//			if string.lowercased().contains("mi") {
//				return Station.milano
//			} else {
//				return []
//			}
//
//			let r = StationsRequest.autocompleteStation(with: "mi")
//
//		}
	},
	saveFavourites: { _ in .sync { true } } ,
	retrieveFavourites: { .sync { [] }}
)

let live: AppEnvironment = (
	counter: counterEnv,
	login: loginEnv,
	stations: stationsEnv
)
