//
//  GenresListView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-26.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct GenresListView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var topArtists: [Artist] = []
    @State private var topGenresDict: [String: Int] = [:]
    @State private var topGenres: [String] = []
    
    @State private var didRequestArtists = false
    @State private var isLoadingArtists = false
    @State private var artistsNotLoaded = false
    @State private var loadArtistsCancellable: AnyCancellable? = nil
    
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
        NavigationStack {
            ScrollView {
                ForEach(self.topGenresDict.sorted(by: { $0.value > $1.value } ), id: \.key) { genre, count in
                    HStack(alignment: .top) {
                        Text(genre.prefix(1).uppercased() + genre.dropFirst())
                            .font(.callout)
                        Spacer()
                        Capsule()
                            .frame(width: 20 * CGFloat(count), height: 15)
                            .foregroundColor(accentColor)
                    }
                    .padding()
                }
            }
            .padding(.top, 10)
            .onAppear {
                self.getTopGenres()
                
            }
        }
        .navigationTitle("My Genres")
            
        if self.topGenres.count > 0 {
            ForEach(topGenres, id: \.self) { genre in
                Text(genre)
            }
        }
    }
    
    func getTopGenres() {
        self.loadArtistsCancellable = spotify.spotifyAPI
            .currentUserTopArtists(TimeRange(rawValue: "short_term"), limit: 50)
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
                    
                    for artist in self.topArtists {
                        if let genres = artist.genres {
                            for genre in genres {
                                if let _ = self.topGenresDict[genre] {
                                    self.topGenresDict[genre]! += 1
                                } else {
                                    self.topGenresDict[genre] = 1
                                }
                            }
                        }
                    }
                    self.topGenresDict = self.topGenresDict
                        .filter { $0.value > 1 }
                     
                })
    }
}

struct GenresListView_Previews: PreviewProvider {
    static var previews: some View {
        GenresListView()
    }
}
