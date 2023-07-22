//
//  AuthorizationView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-20.
//

import SwiftUI
import Combine

struct AuthorizationView: ViewModifier {
    
    static let animation = Animation.spring()
    let accentColor = ColorModel.accentColor
    let textColor = ColorModel.textColor
    
    @EnvironmentObject var spotify: Spotify
    
    @State private var finishedDelay = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if !spotify.isAuthorized {
                        if self.finishedDelay {
                            authorizationView
                        }
                    }
                }
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(AuthorizationView.animation) {
                        self.finishedDelay = true
                    }
                }
            }
    }
    
    var authorizationView: some View {
        VStack {
            Spacer()
            loginButton
                .padding()
                .shadow(radius: 5)
                .transition(
                    AnyTransition.scale(scale: 1.2)
                        .combined(with: .opacity))
        }
    }
    
    var loginButton: some View {
        Button(action: spotify.authorization) {
            HStack {
                Image("spotify logo white")
                    .interpolation(.high)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Text("Log in with Spotify")
                    .font(.body)
                    .bold()
                    .foregroundColor(textColor)
            }
            .padding()
            .background(accentColor)
            .clipShape(Capsule())
            .shadow(radius: 5)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!spotify.isReceivingTokens)
    }
    
}

struct AuthorizationView_Previews: PreviewProvider {
    static let spotify = Spotify()
    
    static var previews: some View {
        MainView()
            .environmentObject(spotify)
            .onAppear(perform: onAppear)
    }
    
    static func onAppear() {
        spotify.isAuthorized = false
        spotify.isReceivingTokens = true
    }
}
