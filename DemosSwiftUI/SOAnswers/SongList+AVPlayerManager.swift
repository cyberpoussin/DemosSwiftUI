//
//  SwiftUIView31.swift
//  DemosSwiftUI
//
//  Created by Admin on 28/08/2021.
//

import AVFoundation
import Combine
import SwiftUI


struct SongList: View {
    @StateObject var listVM = SongListViewModel()
    var body: some View {
        List(listVM.songVMlist) { cellVM in
            SongCell(songCellVM: cellVM, selectedSong: $listVM.selectedSong)
        }
    }
}

struct SongCell: View {
    @ObservedObject var songCellVM: SongCellViewModel
    @Binding var selectedSong: Song?

    var isSelected: Bool { songCellVM.song.id == selectedSong?.id }
    var body: some View {
        HStack {
            Text(songCellVM.song.name)
            Spacer()
            Button {
                songCellVM.player?.pausePlayer()
                if isSelected {
                    selectedSong = nil
                } else {
                    songCellVM.player?.launchPlayer(with: "angele")
                    selectedSong = songCellVM.song
                }
            } label: {
                Image(systemName: isSelected ? "playpause" : "play")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

class SongCellViewModel: ObservableObject, Identifiable {
    let id = UUID()
    var song: Song
    var player: AVPlayerManager?
    init(song: Song, player: AVPlayerManager? = nil) {
        self.song = song
    }
}

class SongListViewModel: ObservableObject {
    var songVMlist: [SongCellViewModel]
    @Published var selectedSong: Song?
    var player: AVPlayerManager = AVPlayerManager()
    init() {
        songVMlist = [
            .init(song: .init(name: "Bala")),
            .init(song: .init(name: "Folk Lore")),
        ]
        _ = songVMlist.map {$0.player = player}
    }
}

class AVPlayerManager {
    var audioPlayer: AVAudioPlayer?
    func launchPlayer(with title: String) {
        guard let dataAsset = NSDataAsset(name: title) else { return }
        audioPlayer = try? perform(AVAudioPlayer(data: dataAsset.data, fileTypeHint: AVFileType.wav.rawValue),
                                 orThrow: AudioLoaderError.loadPlayer)
        audioPlayer?.play()
    }
    func pausePlayer() {
        audioPlayer?.pause()
    }
}

struct Song: Identifiable {
    let id = UUID()
    let name: String
    // let songMP3: Data
    // let image: Image
}

struct SwiftUIView31_Previews: PreviewProvider {
    static var previews: some View {
        SongList()
    }
}
