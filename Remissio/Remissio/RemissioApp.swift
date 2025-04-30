//
//  RemissioApp.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 10/03/25.
//

import SwiftUI

@main
struct RemissioApp: App {
    @StateObject var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isProtectionEnabled && !authManager.isAuthenticated {
                LockScreenView(authManager: authManager)
            } else {
                MainTabView()
                    .environmentObject(authManager)
            }
        }
    }
}
