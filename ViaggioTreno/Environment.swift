//
//  Environment.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation
import RxComposableArchitecture
import Features

public typealias AppEnvironment = (
    counter: CounterViewEnvironment,
    login: LoginViewEnvironment
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

let live: AppEnvironment = (
    counter: counterEnv,
    login: loginEnv
)
