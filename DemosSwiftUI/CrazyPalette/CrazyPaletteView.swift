//
//  CrazyPaletteView.swift
//  NewFlowerApp
//
//  Created by Admin on 14/02/2021.
//

import Combine
import SwiftUI

enum CrazyPaletteState: Equatable {
    static func == (lhs: CrazyPaletteState, rhs: CrazyPaletteState) -> Bool {
        switch (lhs, rhs) {
        case let (.weGotIt(lPalette), .weGotIt(rPalette)):
            return lPalette.colors == rPalette.colors
        case (.showFavorites, .showFavorites): return true
        case (.errorService, .errorService): return true

        default: return false
        }
    }

    case weGotIt(palette: AnyPalette), showFavorites, noConnexion, errorService, justLaunched, serviceNotBound
}

class CrazyPaletteViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    let paletteService: PaletteService
    @Published var state: CrazyPaletteState
    init(paletteService: PaletteService, state: CrazyPaletteState = .justLaunched) {
        self.paletteService = paletteService
        self.state = state
    }

    func fetchColors(from seedColor: Color? = nil) {
        paletteService.fetchPalette(from: seedColor)
            .receive(on: DispatchQueue.main)
            .sink { result in
                print(result.debugDescription)
                if let palette = result {
                    self.state = .weGotIt(palette: palette)
                } else {
                    self.state = .errorService
                }
            }
            .store(in: &cancellables)
    }
}

struct CrazyPaletteView: View {
    @ObservedObject var paletteVM: CrazyPaletteViewModel

    @State private var offset: CGSize = CGSize(width: 0, height: 0)
    @State private var iconIsAnimated: Bool = false
    @State private var refreshing: Bool = false
    @GestureState var swipeDirection: DragState = .none
    @State private var cpt = 0
    var nbOfColumns: Int { 5 - cpt % 5 }

    var favoriteAction: (AnyPalette) -> () = {_ in 
            print("add to favorites")
        }
    var closingAction: () -> () = {
        print("close")
    }
    
    
    var body: some View {
        // if case let .weGotIt(palette) = appState {
        GeometryReader { geo in
            VStack {
                switch paletteVM.state {
                case .errorService:
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        Color.pink
                        Text("Quelle erreur !")
                    }
                    .offset(y: offset.height)
                    .gesture(dragGesture(geo: geo))
                case let .weGotIt(palette):
                    ZStack {
                        Color.white.ignoresSafeArea()
                        Color.red.opacity(0.1).ignoresSafeArea()
                        CrazyPaletteIcons(iconIsAnimated: $iconIsAnimated, offset: offset)
                        CrazyPaletteColorsView(paletteVM: paletteVM, nbOfColumns: nbOfColumns, offsetWidth: offset.width, geo: geo, initialPalette: palette)
                        Button("erreur") {
                            paletteVM.state = .errorService
                        }
                    }
                    .offset(y: offset.height)
                    .gesture(dragGesture(geo: geo, palette: palette))
                    //.transition(.move(edge: .bottom))


                case .justLaunched:
                    Text("chargement")
                        .onAppear {
                            //offset = .zero
                            paletteVM.fetchColors()
                        }
                default:
                    EmptyView()
                }
            }
            .animation(.linear(duration: 1), value: paletteVM.state)
        }
        .ignoresSafeArea()
        

        // }
    }
}

extension CrazyPaletteView {
    func dragGesture(geo: GeometryProxy, palette: AnyPalette? = nil) -> some Gesture {
        return DragGesture()
            .updating($swipeDirection) { value, state, _ in
                guard !iconIsAnimated && !refreshing else { return }

                if state == .none &&
                    abs(value.translation.width) > abs(value.translation.height) {
                    state = .horizontal
                } else if state == .none &&
                    abs(value.translation.width) < abs(value.translation.height) {
                    state = .vertical
                } else if abs(value.translation.width) < abs(geo.size.width / 3) &&
                    abs(value.translation.width) > abs(value.translation.height) {
                    state = .horizontal
                }

                if state == .horizontal &&
                    abs(value.translation.width) > abs(geo.size.width / 3) {
                    switch value.translation.width {
                    case ..<0:
                        state = .leftSwipe
                        return
                    case 0...:
                        state = .rightSwipe
                        return
                    default: break
                    }
                }

                if state == .vertical &&
                    abs(value.translation.height) > 170 {
                    switch value.translation.height {
                    case ..<0: state = .upSwipe
                    case 0...: state = .downSwipe
                    default: break
                    }
                }
            }
            .onChanged { value in
                guard !iconIsAnimated && !refreshing else { return }
                print(swipeDirection)
                switch swipeDirection {
                case .leftSwipe, .rightSwipe:
                    withAnimation(Animation.linear(duration: 0.5)) {
                        iconIsAnimated = true
                    }
                    withAnimation(Animation.linear(duration: 0.5).delay(0.4)) {
                        offset.width = 0
                    }
                    refreshing = true

                    if swipeDirection == .leftSwipe {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            iconIsAnimated = false
                            if let palette = palette,
                               let newPalette = AnyPalette( from: palette.colors.shuffled()) {
                                favoriteAction(palette)
                                paletteVM.state = .weGotIt(palette: newPalette)
                            }
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            iconIsAnimated = false
                            print("changement de couleur")
                            paletteVM.fetchColors()
                        }
                    }

                case .horizontal:
                    offset.width = value.translation.width
                    withAnimation {
                        offset.height = 0
                    }
                case .vertical:
                    withAnimation {
                        offset.width = 0
                        if value.translation.height > 0 {
                            offset.height = value.translation.height
                        }
                    }
                case .upSwipe:
                    refreshing = true
                    cpt += 1
                case .downSwipe:
                    refreshing = true
//                    withAnimation(.linear(duration: 1)) {
//                        offset.height = geo.size.height
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        paletteVM.state = .showFavorites
//                    }
                    closingAction()
                case .none:
                    return
                }
            }
            .onEnded { _ in
                if !refreshing {
                    withAnimation {
                        offset = CGSize(width: 0, height: 0)
                    }
                }
                //offset.height = 0
                refreshing = false
            }
    }
}

struct CrazyPaletteView_Previews: PreviewProvider {
    
    static var previews: some View {
        let palette = AnyPalette(from: [.white, .red, .black, .blue, .purple])!


        return Group {
            CrazyPaletteView(paletteVM: CrazyPaletteViewModel(paletteService: PalettDotEsService(), state: .weGotIt(palette: palette)))
            CrazyPaletteView(paletteVM: CrazyPaletteViewModel(paletteService: PalettDotEsService(), state: .errorService))
            CrazyPaletteView(paletteVM: CrazyPaletteViewModel(paletteService: PalettDotEsService(), state: .justLaunched))
        }
    }
}

struct CrazyPaletteIcons: View {
    @Binding var iconIsAnimated: Bool
    var iconColor: Color = .blue
    var offset: CGSize

    var body: some View {
        HStack {
            ZStack {
                Image(systemName: "trash")
                    .opacity(Double(0.008 * abs(offset.width)))
                    .font(.title)
                    .padding(30)

                Image(systemName: "trash.fill")
                    .foregroundColor(iconColor)
                    .opacity(iconIsAnimated ? 1 : 0)
                    .font(.title)
                    .padding(30)
            }
            .scaleEffect(iconIsAnimated ? 2 : 1)
            Spacer()
            ZStack {
                Image(systemName: "heart")
                    .opacity(Double(0.008 * abs(offset.width)))
                    .font(.title)
                    .padding(30)

                Image(systemName: "heart.fill")
                    .foregroundColor(iconColor)
                    .opacity(iconIsAnimated ? 1 : 0)
                    .font(.title)
                    .padding(30)
            }
            .scaleEffect(iconIsAnimated ? 2 : 1)
        }
    }
}

struct CrazyPaletteColorsView: View {
    @ObservedObject var paletteVM: CrazyPaletteViewModel
    var nbOfColumns: Int
    var heightModifier: CGFloat { CGFloat(nbOfColumns) / CGFloat(5) }
    var offsetWidth: CGFloat
    var geo: GeometryProxy
    var initialPalette: AnyPalette
    @State private var shuffledPalette: AnyPalette? = nil
    var palette: AnyPalette {
        if let palette = shuffledPalette {
            return palette
        }
        return initialPalette
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0 ... nbOfColumns - 1, id: \.self) { idx in
                    palette.colors[idx].color
                        .frame(height: geo.size.height * heightModifier)
                        .onTapGesture {
                            paletteVM.fetchColors(from: palette.colors[idx].color)
                        }
                }
            }
            VStack(spacing: 0) {
                ForEach(nbOfColumns ..< palette.colors.count, id: \.self) { idx in
                    palette.colors[idx].color
                        .frame(width: geo.size.width)
                        .onTapGesture {
                            paletteVM.fetchColors(from: palette.colors[idx].color)
                        }
                }
            }
            .padding(-2)
        }
        .cornerRadius(12)
        .offset(x: offsetWidth)
    }
}
