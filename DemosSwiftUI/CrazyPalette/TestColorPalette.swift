//
//  TestColorPalette.swift
//  NewFlowerApp
//
//  Created by Admin on 09/02/2021.
//

import Combine
import SwiftUI

enum AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.showPalette, .showPalette): return true
        case (.showFavorites, .showFavorites): return true
        case (.noConnexion, .noConnexion): return true
        case (.justLaunched, .justLaunched): return true
        default: return false
        }
    }

    case showPalette, showFavorites, noConnexion, justLaunched
}

class PaletteViewModel: ObservableObject {
    @AppStorage("favorites") var storedFavs: Data = Data()
    var favorites: [AnyPalette] {
        print("get favorites")
        let result = UserDefaults.standard.data(forKey: "favorites")
            .flatMap {
                do {
                   return try JSONDecoder().decode([AnyPalette].self, from: $0)
                } catch {
                    print(error)
                    return nil
                }
            } ?? []
        print(result)
        return result as! [AnyPalette]
    }

    private var cancellables: Set<AnyCancellable> = []
    let paletteService: PaletteService
    @Published var state: AppState

    init(paletteService: PaletteService, state: AppState = .justLaunched) {
        self.paletteService = paletteService
        self.state = state
        UITableView.appearance().backgroundColor = .clear

    }

    func addToFavorites(palette: AnyPalette) {
        let newFavs = favorites + [palette]
        do {
            let favsReadyToSave = try JSONEncoder().encode(newFavs)
            storedFavs = favsReadyToSave

        } catch {
            print(error)
        }
//        if let favs = favsReadyToSave {
//            storedFavs = favs
//        }
    }
}

struct TestColorPalette: View {
    @ObservedObject var paletteVM = PaletteViewModel(paletteService: ColorMindService())
    @ObservedObject var crazyPaletteViewModel = CrazyPaletteViewModel(paletteService: ColorMindService())
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Color.red.opacity(0.1).ignoresSafeArea()
            FavoritesPalettesView(favoritesVM: FavoritesViewModel(palettes: paletteVM.favorites), appState: $paletteVM.state)
                .onAppear {
                    crazyPaletteViewModel.fetchColors()
                }
            HStack {
                switch paletteVM.state {
                case .showPalette:
                    CrazyPaletteView(
                        paletteVM: crazyPaletteViewModel, favoriteAction: paletteVM.addToFavorites, closingAction: {
                            paletteVM.state = .showFavorites
                        })
                        .onAppear {
                            if case .weGotIt = crazyPaletteViewModel.state {
                            } else {
                                crazyPaletteViewModel.fetchColors()
                            }
                        }
                        .transition(.move(edge: .bottom))

                default:
                    EmptyView()
                }
            }
            .animation(.linear(duration: 0.3), value: paletteVM.state)
        }
    }
}

struct TestColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TestColorPalette()
                .preferredColorScheme(.dark)
            TestView(service: PalettDotEsService())
        }
    }
}

class FavoritesViewModel: ObservableObject {
    @Published var palettes: [AnyPalette]
    @AppStorage("favorites") var storedFavs: Data = Data()

    init(palettes: [AnyPalette]) {
        self.palettes = palettes
    }

    func removePalettes(at offsets: IndexSet) {
        palettes.remove(atOffsets: offsets)
        saveFavorites(palettes: palettes)
    }

    func saveFavorites(palettes: [AnyPalette]) {
        if let favs = try? JSONEncoder().encode(palettes) {
            storedFavs = favs
        }
    }
}

func fetchColorInfo(color: PaletteColor) -> AnyPublisher<PaletteColor?, Never>{
    URLSession.shared.dataTaskPublisher(for: URL(string: "http://thecolorapi.com/id?hex=\(color.color.hexaRGB?.dropFirst() ?? "rien")")!)
        .map { value in
            let data = value.data
            print(String(data: data, encoding: .utf8))
            var result: String?
            // make sure this JSON is in the format we expect
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let jsonName = json["name"] as? NSDictionary,
               let value = jsonName["value"] {
                result = value as? String
            }
            var palResult = color
            palResult.name = result
            return palResult
            // print(String(data: data, encoding: .utf8))
        }
        .catch { error -> AnyPublisher<PaletteColor?, Never> in
            print(error)
            return Just(nil).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

struct FavoritesPalettesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    @Binding var appState: AppState
    @State var cancellables: Set<AnyCancellable> = []
 
           
    var body: some View {
        VStack {
            Button("Launch CrazyPalette") {
                appState = .showPalette
            }
            Button("remove") {
                favoritesVM.removePalettes(at: IndexSet(0 ... 1))
            }
            Button("Info color") {
                
            }
            List {
                ForEach(favoritesVM.palettes.indices, id: \.self) { idx in
                    HStack(spacing: 0) {
                        PaletteDetailsView(detailsVM: PaletteDetailsViewModel(palette: $favoritesVM.palettes[idx]))
                    }
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                }
                
                .onDelete(perform: favoritesVM.removePalettes)
                .listRowBackground(ZStack {
                    Color.white.ignoresSafeArea()
                    Color.red.opacity(0.1).ignoresSafeArea()
                })
            }
            .onAppear {
                favoritesVM.saveFavorites(palettes: favoritesVM.palettes)
            }
            .onChange(of: favoritesVM.palettes) {value in
                favoritesVM.saveFavorites(palettes: value)
            }
        }


    }
}

class PaletteDetailsViewModel: ObservableObject {
    //@Published var names: [String]
    @Binding var palette: AnyPalette
    var cancellable: AnyCancellable? = nil
    init(palette: Binding<AnyPalette>) {
        self._palette = palette
        self.cancellable = palette.wrappedValue.colors.publisher
            .map { value -> PaletteColor in
                //print("\(value.hexaRGB!)")
                return value
                
            }
            //.delay(for: 1, scheduler: RunLoop.main)
            .flatMap {paletteColor in
                fetchColorInfo(color: paletteColor)
            }
            .receive(on: DispatchQueue.main)
            .sink { value in
                guard let paletteColor = value else {return}
                guard let idx = palette.wrappedValue.colors.firstIndex(where: {$0.color == paletteColor.color}) else {return}
                self.palette.colors[idx] = paletteColor
            }
    }
    
}

struct PaletteDetailsView: View {
    @ObservedObject var detailsVM: PaletteDetailsViewModel
        
    var body: some View {
        ForEach(detailsVM.palette.colors.indices, id: \.self) { idx in
            ZStack {
                detailsVM.palette.colors[idx].color
                VStack {
                    Text("\(detailsVM.palette.colors[idx].color.hexaRGB!)")
                    Text("\(detailsVM.palette.colors[idx].name ?? "pas encore de nom")")
                }
            }
                .frame(minHeight: 100)
        }
    }
}

class TestViewModel: ObservableObject {
    var bag: AnyCancellable?
    var colorsInHex: [String] = []

    @Published var colors: [String] = ["chargement..."]
    func fetchRandomColors() {
        let url = URL(string: "https://palett.es/API/v1/palette/monochrome/over/\(Double.random(in: 0 ... 1))")
        bag = URLSession.shared.dataTaskPublisher(for: url!)
            .map { data, _ in
                data
            }
            .decode(type: [String].self, decoder: JSONDecoder())
            .replaceError(with: ["erreur"])
            .receive(on: DispatchQueue.main)
            .sink { dataInString in
                self.colors = dataInString
            }
    }
}

struct TestView: View {
    var service: PaletteService
    @ObservedObject var viewModel = TestViewModel()
    var body: some View {
        VStack {
            Button("Random colors") {
                viewModel.fetchRandomColors()
            }
            List(viewModel.colors, id: \.self) { color in
                Text(color)
            }
        }
    }
}

enum DragState {
    case horizontal, vertical, upSwipe, downSwipe, leftSwipe, rightSwipe, none
}
