//
//  ContentView.swift
//  NewFlowerApp
//
//  Created by Admin on 03/02/2021.
//

import SwiftUI

struct MusicPlayerView: View {
    @State private var played = false
    @State private var firstTime = true

    var body: some View {
        Button {
            played.toggle()
            if firstTime {
                try? playFromAssets(filename: "angele")
                firstTime = false
            } else if !played {
                audioPlayer?.pause()
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
