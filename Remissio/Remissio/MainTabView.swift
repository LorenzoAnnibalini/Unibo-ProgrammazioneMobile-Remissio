//
//  MainTabView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 22/03/25.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        
        TabView {
            
            HomePageView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SegnalazioniView()
                .tabItem {
                    Image(systemName: "exclamationmark.bubble.fill")
                    Text("Segnalazioni")
                }
            
            ProfiloView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profilo")
                }
        }
        .onAppear {
            // Modifica lo sfondo della TabBar
            UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
        .environmentObject(AuthenticationManager())
    }
}
