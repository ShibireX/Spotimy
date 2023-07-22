//
//  SpotimyApp.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-19.
//

import SwiftUI

@main
struct SpotimyApp: App {
    @StateObject var spotify = Spotify()
    
    var body: some Scene {
        
        WindowGroup {
            MainView()
                .environmentObject(spotify)
            }
        }
}

