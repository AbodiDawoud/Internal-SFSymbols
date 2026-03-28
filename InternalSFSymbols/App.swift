//
//  InternalSFSymbolsApp.swift
//  InternalSFSymbols
    

import SwiftUI

@main
struct InternalSFSymbolsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(Bookmarks())
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        print(">>> AppDelegate: applicationWillTerminate")
        UserDefaults.standard.set(true, forKey: "has_seen_cardView")
    }
}
