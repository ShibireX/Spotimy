//
//  AudioPlayerView.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-25.
//

import SwiftUI
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    @Published var activePlayer: AVPlayer?

    init() {
        setupObservers()
    }

    func playAudio(player: AVPlayer) {
        activePlayer?.pause()
        activePlayer = player
        activePlayer?.play()
    }

    func pauseAudio() {
        activePlayer?.pause()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    @objc private func playerDidFinishPlaying() {
        activePlayer = nil
    }
}


struct AudioPlayerView: View {
    let audioURL: URL
    let accentColor = ColorModel.accentColor

    @State private var isPlaying = false
    
    @EnvironmentObject var audioManager: AudioManager
    private var player: AVPlayer!

    init(audioURL: URL) {
        self.audioURL = audioURL
        self.player = AVPlayer(url: audioURL)
    }

    var body: some View {
        VStack {
            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 10)
                    .padding(.top, 15)
                    .foregroundColor(accentColor)
            }
        }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch {
                print("Error setting AVAudioSession category: \(error)")
            }
        }
        .onChange(of: audioManager.activePlayer) { newValue in
             isPlaying = newValue == player
         }
    }

    private func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            audioManager.playAudio(player: player)
        } else {
            audioManager.pauseAudio()
        }
    }
}
