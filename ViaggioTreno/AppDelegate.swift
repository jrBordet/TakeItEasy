//
//  AppDelegate.swift
//  AlarmsDemo
//
//  Created by Jean Raphael Bordet on 17/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import RxComposableArchitecture
import SceneBuilder
import FileClient
import Styling

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
//		let container = Scene<ArrivalsDeparturesContainerViewController>().render()
//		
//		container.store = Store<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction>(
//			initialValue: ArrivalsDeparturesViewState(selectedStation: nil, departures: [], arrivals: []),
//			reducer: arrivalsDeparturesViewReducer,
//			environment: arrivalsDeparturesViewEnvLive
//		)
		
		let rootScene = Scene<HomeViewController>().render()
		
		rootScene.store = applicationStore.view(
			value: { $0.homeState },
			action: { .home($0) }
		)
		
		self.window?.rootViewController = UINavigationController(rootViewController: rootScene)
		
		self.window?.makeKeyAndVisible()
		self.window?.backgroundColor = .white
		
		return true
	}
}

struct Factory {
	static var stations: StationsViewController = Scene<StationsViewController>().render()
	
	//	static func stations(with store: Store<AppState, AppAction>) -> StationsViewController {
	//		let vc = Scene<StationsViewController>().render()
	//
	//		vc.store = store.view(
	//			value: { $0.stations },
	//			action: { .stations($0) }
	//		)
	//
	//		return vc
	//	}
}
