//
//  AppDelegate.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/12/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var shared: AppDelegate? { return UIApplication.shared.delegate as? AppDelegate }
	var window: UIWindow?
	
	func application(_ application:UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey:Any]?) -> Bool {
		VisitorManager.shared.prepare()
		
		let mainWindow = UIWindow(frame:UIScreen.main.bounds)
		self.window = mainWindow
		
		mainWindow.rootViewController = LandingViewController()
		mainWindow.makeKeyAndVisible()
		
		return true
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		VisitorManager.shared.refresh()
	}
}
