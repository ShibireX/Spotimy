//
//  RectangleView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-22.
//

import SwiftUI

struct RectangleView<Content: View>: View {
    let content: Content
    let accentColor = ColorModel.accentColor
    let mainColor = ColorModel.mainColor

    var body: some View {
        content
            .frame(width: 500, height: 150)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(mainColor, lineWidth: 0.5)
            )
            .shadow(radius: 50)
    }
}
