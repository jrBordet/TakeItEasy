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

func assert(_ lhs: Bool) {
    guard lhs else { fatalError() }
    return
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
             // Code only executes when tests are running
            return true
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
//        let rootScene = Scene<AlarmsCollectionViewController>().render()
//
//        rootScene.store = applicationStore.view(
//            value: { $0.alarmsCollectionView },
//            action: { AppAction.alarmsCollection($0) }
//        )
//
//        self.window?.rootViewController = UINavigationController(rootViewController: rootScene)
        
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = .white
        
        return true
    }
}
