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
                        NavigationLink {
                            InsightView()
                        } label: {
                            RectangleView(content: Text("My Artists"))
                                .background(mainColor)
                        }
                        RectangleView(content: Text("My Tracks"))
                            .background(mainColor)
                        RectangleView(content: Text("My Genres"))
                            .background(mainColor)
                        RectangleView(content: Text("My Quizzes"))
                            .background(mainColor)
                    })
                    .foregroundColor(textColor)
                }
            }
            .navigationTitle("Home")
            .modifier(NavigationBarShadowModifier())
            
        }
        
    }
}

struct NavigationBarShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .frame(height: 20)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
