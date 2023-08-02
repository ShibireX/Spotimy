//
//  RecommendationsListView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-26.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct RecommendationsListView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var topTracks: [SpotifyURIConvertible] = []
    @State private var recommendations: [Track] = []
    @State private var chosenTimeFrame: TimeFrame = TimeFrame.midTerm
    
    @State private var didRequestTracks = false
    @State private var isLoadingTracks = false
    @State private var tracksNotLoaded = false
    @State private var loadTracksCancellable: AnyCancellable? = nil
    
    @State private var didRequestRecommendations = false
    @State private var isLoadingRecommendations = false
    @State private var recommendationsNotLoaded = false
    @State private var loadRecommendationsCancellable: AnyCancellable? = nil
    
    @StateObject private var audioManager = AudioManager()
    
    let mainColor = ColorModel.mainColor
    let textColor = ColorModel.textColor
    let accentColor = ColorModel.accentColor
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(mainColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(textColor)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(textColor)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(accentColor)
    }
    
    var body: some View {
        Group {
            ZStack {
                mainColor.ignoresSafeArea()
                VStack {
                    Picker("", selection: $chosenTimeFrame) {
                        Text("Short Term").tag(TimeFrame.shortTerm)
                        Text("Mid Term").tag(TimeFrame.midTerm)
                        Text("Long Term").tag(TimeFrame.longTerm)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.bottom, 5)
                    .onChange(of: chosenTimeFrame) { newTimeFrame in
                        let timeFrameString: String
                        switch newTimeFrame {
                        case .longTerm:
                            timeFrameString = "long_term"
                        case .midTerm:
                            timeFrameString = "medium_term"
                        case .shortTerm:
                            timeFrameString = "short_term"
                        }
                        getTopTracks(timeFrame: timeFrameString)
                        
                    }
                    if recommendations.isEmpty {
                        if isLoadingRecommendations {
                            Spacer()
                            HStack {
                                ProgressView()
                                    .padding()
                            }
                            Spacer()
                        }
                        else if recommendationsNotLoaded {
                            Spacer()
                            Text("Could Not Load Tracks")
                                .font(.title)
                            Spacer()
                        }
                        else {
                            Spacer()
                            Text("No Tracks")
                                .font(.title)
                            Spacer()
                        }
                    }
                    else {
                        ScrollView {
                            ForEach(recommendations, id: \.self) { recom in
                                HStack(alignment: .top) {
                                    AsyncImage(url: recom.album?.images?.largest?.url) { image in
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(10)
                                    } placeholder: {
                                        Image(systemName: "music.note")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                            .cornerRadius(10)
                                    }
                                    Text(recom.name)
                                        .padding(.leading, 8)
                                        .padding(.top, 15)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if let playbackURL = recom.previewURL {
                                        AudioPlayerView(audioURL: playbackURL)
                                            .environmentObject(audioManager)
                                    } else {
                                        Image(systemName: "play")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .padding(.trailing, 10)
                                            .padding(.top, 15)
                                            .foregroundColor(accentColor)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .foregroundColor(textColor)
            }
        }
        .navigationTitle("My Recommendations")
        .onAppear {
            if !self.didRequestTracks {
                self.getTopTracks(timeFrame: "medium_term")
            }
        }
    }
    
    func getTopTracks(timeFrame: String) {
        self.didRequestTracks = true
        self.isLoadingTracks = true
        self.topTracks = []
        
        self.loadTracksCancellable = spotify.spotifyAPI
            .currentUserTopTracks(TimeRange(rawValue: timeFrame), limit: 5)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingTracks = false
                    switch completion {
                        case .finished:
                            self.tracksNotLoaded = false
                        case .failure(let error):
                            self.tracksNotLoaded = true
                            print(error)
                    }
                },
                receiveValue: { topTracks in
                    let tracks = topTracks.items
                        .compactMap { $0.id }
                    let formattedTrackIDs = tracks.map { "spotify:track:" + $0 }
                    self.topTracks.append(contentsOf: formattedTrackIDs)
                    
                    self.getRecommendations(tracks: self.topTracks)
                })
    }
    
    func getRecommendations(tracks: [SpotifyURIConvertible]) {
        self.didRequestRecommendations = true
        self.isLoadingRecommendations = true
        self.recommendations = []
        
        
        self.loadRecommendationsCancellable = spotify.spotifyAPI
            .recommendations(TrackAttributes(seedTracks: tracks), market: "SE")
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingRecommendations = false
                    switch completion {
                        case .finished:
                            self.recommendationsNotLoaded = false
                        case .failure(let error):
                            self.recommendationsNotLoaded = true
                            print(error)
                    }
                },
                receiveValue: { topRecommendations in
                    let recoms = topRecommendations.tracks
                        .filter { $0.id != nil }
                    self.recommendations.append(contentsOf: recoms)
                }
            )
    }
}

struct RecommendationsListView_Previews: PreviewProvider {
    static var spotify = Spotify()
    
    static var previews: some View {
        RecommendationsListView()
            .environmentObject(spotify)
    }
}
