//
//  whatShouldWeEatApp.swift
//  whatShouldWeEat
//
//  Created by Sam Kujovich on 7/20/25.
//

import SwiftUI
import Firebase
import UIKit

@main
struct whatShouldWeEatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseConfig.shared.configure()
        return true
    }
}
