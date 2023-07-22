//
//  InsightView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-20.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct InsightView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var topArtists: [Artist] = []
    
    @State private var didRequestArtists = false
    @State private var isLoadingArtists = false
    @State private var artistsNotLoaded = false
    
    @State private var loadArtistsCancellable: AnyCancellable? = nil
    
    let mainColor = ColorModel.mainColor
    let textColor = ColorModel.textColor
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(mainColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(textColor)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(textColor)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
            Group {
                ZStack {
                    mainColor.ignoresSafeArea()
                    if topArtists.isEmpty {
                        if isLoadingArtists {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Fetching Artists")
                                    .font(.title)
                            }
                        }
                        else if artistsNotLoaded {
                            Text("Could Not Load Artists")
                                .font(.title)
                        }
                        else {
                            Text("No Artists")
                                .font(.title)
                        }
                    }
                    else {
                        ScrollView {
                            ForEach(topArtists, id: \.id) { artist in
                                HStack(alignment: .top) {
                                    AsyncImage(url: artist.images?.largest?.url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(10)
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                            .cornerRadius(10)
                                    }
                                    Text(artist.name)
                                        .padding(.leading, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .foregroundColor(textColor)
        }
        .navigationTitle("Your Artists")
        .onAppear {
            if !self.didRequestArtists {
                self.getTopArtists()
            }
        }
    }
    
    func getTopArtists() {
        self.didRequestArtists = true
        self.isLoadingArtists = true
        self.topArtists = []
        
        self.loadArtistsCancellable = spotify.spotifyAPI
            .currentUserTopArtists()
            .extendPages(spotify.spotifyAPI)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingArtists = false
                    switch completion {
                        case .finished:
                            self.artistsNotLoaded = false
                        case .failure(let error):
                            self.artistsNotLoaded = true
                            print(error)
                    }
                },
                receiveValue: { topArtists in
                    let artists = topArtists.items
                        .filter { $0.id != nil }
                    self.topArtists.append(contentsOf: artists)
                })
    }
    
}

struct InsightView_Previews: PreviewProvider {
    static var spotify = Spotify()
    
    static var previews: some View {
        InsightView()
            .environmentObject(spotify)
    }
}
