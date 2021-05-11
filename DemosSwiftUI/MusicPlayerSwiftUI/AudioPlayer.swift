import AVFoundation
import SwiftUI

var audioPlayer: AVAudioPlayer?

enum AudioLoader {
    case fromResource(URL)
    case fromAsset(NSDataAsset)
}

enum AudioLoaderError: Error {
    case resourceNotFound
    case assetNotFound
    case loadPlayer
}

func playFromResources(filename: String, fileExtension: String) throws {
    guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
        throw AudioLoaderError.resourceNotFound
    }
    try playFrom(audioLoader: AudioLoader.fromResource(url))
}

func playFromAssets(filename: String) throws {
    guard let dataAsset = NSDataAsset(name: filename) else {
        throw AudioLoaderError.assetNotFound
    }
    try playFrom(audioLoader: AudioLoader.fromAsset(dataAsset))
}

func playFrom(audioLoader: AudioLoader) throws {
    switch audioLoader {
    case .fromResource(let url):
        audioPlayer = try perform(AVAudioPlayer(contentsOf: url),
                                  orThrow: AudioLoaderError.loadPlayer)
    case .fromAsset(let dataAsset):
        audioPlayer = try perform(AVAudioPlayer(data: dataAsset.data, fileTypeHint: AVFileType.wav.rawValue),
                                  orThrow: AudioLoaderError.loadPlayer)
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
        audioPlayer?.play()
    }
}

func perform<T>(_ expression: @autoclosure () throws -> T, orThrow errorExpression: @autoclosure () -> Error) throws -> T {
    do {
        return try expression()
    } catch {
        throw errorExpression()
    }
}
