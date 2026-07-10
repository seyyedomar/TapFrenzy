//
//  PlayHubApp.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-07.
import SwiftUI

@main
struct PlayHubApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeTab()
                    .tabItem { Label("Home", systemImage: "gamecontroller") }

                StatsTab()
                    .tabItem { Label("Stats", systemImage: "chart.bar") }

                MapTab()
                    .tabItem { Label("Map", systemImage: "map") }

                SettingsTab()
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
        }
    }
}
