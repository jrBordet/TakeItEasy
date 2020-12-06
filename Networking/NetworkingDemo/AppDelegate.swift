//
//  AppDelegate.swift
//  AppTheme
//
//  Created by Jean Raphael Bordet on 22/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
                
        
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = .white
        
        return true
    }
}
