//
//  RecommendationsListView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-26.
//

import SwiftUI

struct RecommendationsListView: View {
    var trackList: TrackListView = TrackListView()
    var artistList: ArtistListView = ArtistListView()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RecommendationsListView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationsListView()
    }
}
