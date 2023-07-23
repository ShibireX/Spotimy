//
//  HomeView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-21.
//

import SwiftUI

struct HomeView: View {
    let mainColor = ColorModel.mainColor
    let accentColor = ColorModel.accentColor
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
        NavigationStack {
            ZStack {
                mainColor.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: [GridItem()],
                              spacing: 0,
                              content: {
                        ForEach(MenuOption.allCases, id: \.self) { option in
                            NavigationLink {
                                ArtistListView()
                            } label: {
                                MenuItemView(option: option)
                            }
                        }
                    })
                    .foregroundColor(textColor)
                }
            }
            .navigationTitle("Home")
            
        }
    }
}

struct MenuItemView: View {
    let option: MenuOption
    let tintColor = ColorModel.accentColor
    
    var body: some View {
        ZStack {
            Image(option.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.9)
                .grayscale(1)
                .colorMultiply(tintColor)
            Text(option.rawValue)
                .font(.title)
                .shadow(radius: 5)
        }
    }
}

enum MenuOption: String, CaseIterable {
    case artists = "My Artists"
    case tracks = "My Tracks"
    case genres = "My Genres"
    case quizzes = "My Quizzes"
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
