//
//  PassGuardApp.swift
//  PassGuard
//
//  Created by Bryan Mejia on 19/5/24.
//

import SwiftUI

@main
struct PassGuardApp: App {
    
    @StateObject private var userData = UserData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
        }
    }
}
