//
//  AppAction.swift
//  RxComposableArchitectureDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation
import Features

public enum AppAction {
    case counter(CounterViewAction)
    case login(LoginViewAction)
}
