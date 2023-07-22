//
//  MainView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-20.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct MainView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        Group {
            if !spotify.isAuthorized {
                LandingView()
            }
            else if spotify.isAuthorized {
                NavigationStack {
                    HomeView()
                        .toolbar {
                            ToolbarItem {
                                Button("Log out") {
                                    spotify.spotifyAPI.authorizationManager.deauthorize()
                                }
                            }
                        }
                }
            }
                
        }
        .modifier(AuthorizationView())
        .onOpenURL(perform: handleURL(_:))
    }
    
    func handleURL(_ url: URL) {
        guard url.scheme == self.spotify.loginCallback.scheme else {
            print("Unexpected scheme: \(url)")
            return
        }
        print("Received redirect from Spotify: \(url)")
        spotify.isReceivingTokens = true
        
        spotify.spotifyAPI.authorizationManager.requestAccessAndRefreshTokens(
                redirectURIWithQuery: url,
                state: spotify.authorizationString)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                self.spotify.isReceivingTokens = false
                
                if case .failure(let error) = completion {
                    print("Could not retrieve access and refresh tokens: \(error)")
                }
            })
        .store(in: &cancellables)
        self.spotify.authorizationString = String.randomURLSafe(length: 128)
    }
    
}

struct MainView_Previews: PreviewProvider {
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = false
        return spotify
    }()
    
    static var previews: some View {
        MainView()
            .environmentObject(spotify)
    }
}
