//
//  LandingView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-21.
//

import SwiftUI

struct LandingView: View {
    let mainColor = ColorModel.mainColor
    let accentColor = ColorModel.accentColor
    let textColor = ColorModel.textColor
    
    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()
            VStack {
                Text("Spotimy")
                    .font(.title)
                    .bold()
            }
            .foregroundColor(textColor)
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
