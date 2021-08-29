//
//  ContentView.swift
//  NewFlowerApp
//
//  Created by Admin on 03/02/2021.
//
import AVFoundation
import SwiftUI

struct MusicPlayerView: View {
    @State private var played = false
    @State private var firstTime = true
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        Button {
            played.toggle()
            if firstTime {
                guard let dataAsset = NSDataAsset(name: "angele") else { return }
                audioPlayer = try? perform(AVAudioPlayer(data: dataAsset.data, fileTypeHint: AVFileType.wav.rawValue),
                                         orThrow: AudioLoaderError.loadPlayer)
                audioPlayer?.play()
                firstTime = false
                
            } else if !played {
                audioPlayer?.stop()
            } else {
                audioPlayer?.play()
            }
        } label: {
            Image(systemName: played ? "pause" : "play")
        }
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
    }
}
