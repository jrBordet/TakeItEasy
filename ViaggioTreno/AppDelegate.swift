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
		
		let s: StationsViewController = UIViewController.stations
		
		s.store = applicationStore.view(
			value: { $0.stations },
			action: { .stations($0) }
		)
		let rootScene = s
		
		self.window?.rootViewController = UINavigationController(rootViewController: rootScene)
		
		self.window?.makeKeyAndVisible()
		self.window?.backgroundColor = .white
		
		return true
	}
}

extension UIViewController {
	static var stations: StationsViewController = Scene<StationsViewController>().render()
}

struct Factory {
	static var stations: StationsViewController = Scene<StationsViewController>().render()
}
