//
//  Spotify.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-20.
//

import Foundation
import SpotifyWebAPI
import KeychainAccess
import Combine
import UIKit
import SwiftUI

// Class for handling authorization changes and maintaining them in persistent storage
final class Spotify: ObservableObject {
    
    static let clientID = Environment.value(for: "CLIENT_ID")
    static let clientSecret = Environment.value(for: "CLIENT_SECRET")
    
    // Bool that controls whether or not we can make API requests
    @Published var isAuthorized = false
    // Bool that controls whether or not we are receiving access and refresh tokens
    @Published var isReceivingTokens = false
    
    @Published var activeUser: SpotifyUser? = nil
    
    // Authorization information key
    let authorizationManagerKey = "authorizationManager"
    // Keychain to store authorization information in
    let keychain = Keychain(service: "Adde.Spotimy")
    // Redirect URL after authorization
    let loginCallback = URL(string: "spotimy-app://login-callback")!
    // Secure random string to ensure redirects are made by this app alone (changes after each authorization)
    var authorizationString = String.randomURLSafe(length: 128)
    
    // API instance
    let spotifyAPI = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
        clientId: Spotify.clientID,
        clientSecret: Spotify.clientSecret))
    
    // Set for keeping track of cancellable tasks
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.spotifyAPI.apiRequestLogger.logLevel = .trace
        self.spotifyAPI.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        self.spotifyAPI.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
        
        if let authorizationManagerData = keychain[data: self.authorizationManagerKey] {
            
            do {
                let authorizationManager = try JSONDecoder().decode(AuthorizationCodeFlowManager.self, from: authorizationManagerData)
                print("Found authorization information")
                self.spotifyAPI.authorizationManager = authorizationManager
            }
            catch {
                print("Could not decode authorizationManager from data: \(error)")
            }
        }
        else {
            print("Did not find authorization information")
        }
        
    }
    
    // Method for creating the authorization URL, opening it and setting the authorization scopes
    func authorization() {
        let url = self.spotifyAPI.authorizationManager.makeAuthorizationURL(redirectURI: self.loginCallback,
                                                                            showDialog: true,
                                                                            state: self.authorizationString,
                                                                            scopes: [
                                                                                .userTopRead
                                                                            ])!
        UIApplication.shared.open(url)
    }
    
    // Method for updating the keychain when the authorization information changes
    func authorizationManagerDidChange() {
        withAnimation(AuthorizationView.animation) {
            self.isAuthorized = self.spotifyAPI.authorizationManager.isAuthorized()
        }
        self.getActiveUser()
        
        do {
            let authorizationManagerData = try JSONEncoder().encode(self.spotifyAPI.authorizationManager)
            self.keychain[data: self.authorizationManagerKey] = authorizationManagerData
            print("Saved authorization to keychain")
        }
        catch {
            print("Could not encode authorizationManager: \(error)")
        }
    
    }
    
    // Method for removing authorization from the keychain and logging out the user
    func authorizationManagerDidDeauthorize() {
        withAnimation(AuthorizationView.animation) {
            self.isAuthorized = false
        }
        self.activeUser = nil
        
        do {
            try self.keychain.remove(self.authorizationManagerKey)
            print("Authorization removed from keychain")
        }
        catch {
            print("Could not remove authorization from keychain: \(error)")
        }
    }
    
    // Method for retrieving the current user
    func getActiveUser(ifNil: Bool = true) {
        if ifNil && self.activeUser != nil {
            return
        }
        
        guard self.isAuthorized else { return }
        
        self.spotifyAPI.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Could not retrieve the active user: \(error)")
                    }
                },
                receiveValue: { user in
                    self.activeUser = user
                }
            )
            .store(in: &cancellables)
    }
}
