//
//  NavigationBarShadowModifier.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-23.
//

import SwiftUI

struct NavigationBarShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .frame(height: 10)
        }
    }
}
