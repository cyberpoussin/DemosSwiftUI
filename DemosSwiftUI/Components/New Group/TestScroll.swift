//
//  TestScroll.swift
//  FoodLyon
//
//  Created by foxy on 05/03/2020.
//  Copyright © 2020 AdrienSimon. All rights reserved.
//

import SwiftUI




struct TestScroll<Content: View, Content2: View>: View {
    @State private var isScrollable: Bool = false
    @State private var offsetInsideScrollView: CGPoint = CGPoint(x: 0, y: 0)
    @State private var showMore: Bool = false
    @State private var yDuringAnim: CGFloat = 0
    @ObservedObject var positionController: PositionController = PositionController()
    var sheetWidth: CGFloat { positionController.sheetParameters.sheetWidth }
    var title: () -> Content2
    var content: () -> Content
    
    func handlePressing(_ isPressed: Bool) {
        guard !isPressed else {
            positionController.headerDragged = true
            positionController.isScrolled = true
            return
        }
        
        // MARK: - handle if unpressed
        
        positionController.headerDragged = false
        positionController.isScrolled = false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollableView(offsetInside: self.$offsetInsideScrollView, positionController: self.positionController) {
                        VStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .top) {
                                self.title()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .opacity(0.01)
                            self.content()
                                .frame(width: positionController.sheetWidth)
                                .frame(maxWidth: .infinity)
                            // .frame(width:DeviceManager.sheetWidth - 40)
                                .opacity(self.positionController.offset.y != positionController.bottomLimit ? 1 : 0)
                            Spacer()
                        }
                        
                        // pour éviter de découvrir la vue quand on rebondit
                        HStack {
                            Text("")
                        }
                        .frame(height: positionController.topLimit)
                        .background(Color.blue)
                        // Spacer()
                    }
                    .background(VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                                    .edgesIgnoringSafeArea(.all))
                    .cornerRadius(radius: 15, corners: [.topLeft, .topRight])
                    .shadow(color: Color.gray.opacity(0.25), radius: 4, x: 0, y: -4)
                    .offset(x: self.positionController.offset.x, y: self.positionController.offset.y)
                    .modifier(RecordAnimation(onChange: {
                        print("je m'anime")
                        if $0 == self.positionController.offset.y {
                            self.positionController.isAnimated = false
                        } else {
                            self.positionController.isAnimated = true
                        }
                        self.positionController.stop.y = $0
                        // self.yDuringAnim = $0
                    }, animatableData: self.positionController.offset.y))
                }
                // Header
                VStack {
                    VStack {
                        Rectangle()
                            .frame(width: 50, height: 7)
                            .cornerRadius(5)
                            .padding(.top, 0)
                            .foregroundColor(Color.gray.opacity(0.5))
                        HStack(alignment: .top) {
                            self.title()
                        }
                    }
                    .padding(.bottom, 17)

                    .background(self.offsetInsideScrollView.y <= 0 ?
                                AnyView(Color.clear) :
                                    AnyView(VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)).opacity(Double(self.offsetInsideScrollView.y) / 50)
                                           )
                    )
                    // .frame(height: self.headerHeight - 17)
                    
                    Spacer()
                }
                // .frame(width: DeviceManager.sheetWidth, height: self.headerHeight)
                
                .cornerRadius(radius: 15, corners: [.topLeft, .topRight])
                .offset(x: self.positionController.offset.x, y: self.positionController.offset.y)
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            UIApplication.shared.endEditing(true)
                            self.positionController.headerDragged = true
                            self.positionController.isScrolled = true
                            self.positionController.isAnimated = false
                            withAnimation {
                                self.positionController.totalDrag.y = value.translation.height + self.positionController.oldOffset.y
                            }
                            print("ooold : \(self.positionController.oldOffset.y)")
                            // l'animation doit être gérée dans UIKit
                            if value.translation.height != 0 {
                                withAnimation {
                                    self.offsetInsideScrollView.y = 0
                                }
                            }
                        })
                        .onEnded({ value in
                            self.positionController.velocity.y = value.predictedEndTranslation.height - value.translation.height
                            self.positionController.headerDragged = false
                            self.positionController.isScrolled = false
                            
                        })
                )
                .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 0.2, pressing: handlePressing(_:)) {
                }
            }
            Spacer()
        }
        .background(Color(UIColor.clear))
    }
}


struct TestTestScrollView: View {
    @State private var toggle = true
    var body: some View {
        TestScroll(title: {
            VStack {
                Text("haha")
                Text("haha")
                    .frame(maxWidth: .infinity)
            }
            .border(.blue, width: 1)
            
        }, content: {
            VStack {
//                Button("toggle") {
//                    toggle.toggle()
//                }
//                if toggle {
//                    Text(texte)
//                } else {
//                    Text(texte3)
//                        .frame(maxHeight: .infinity)
//
//                }
                Text(texte3)
                    .frame(maxHeight: .infinity)
                    
            }
            .lineLimit(nil)
            //.frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .border(.purple, width: 1)
        })
            .border(.red, width: 1)
    }
}

struct WrapperTest: View {
    @State private var offset: CGPoint = .zero
    @State private var toggle = true

    var body: some View {
        UIScrollViewWrapper(offset: $offset) {
            VStack {
                Button("toggle") {
                    toggle.toggle()
                }
                if toggle {
                    Text(texte)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                } else {
                    Text(texte3)
                        .frame(maxWidth: UIScreen.main.bounds.width)

                }
                
                    
            }
        }
    }
}
struct TestScroll_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WrapperTest()
            TestTestScrollView()
            Text(texte3)
                .frame(maxHeight: .infinity)
        }
    }
}

var texte = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquen"
var texte2 = "eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique.Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit "
var texte3 = " eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porttitor a est a pellentesque. Vivamus aliquam bibendum feugiat. Nam in magna enim. Vestibulum efficitur elit eget condimentum dictum. Curabitur eu dui eget nisi tempus tristique. Integer quis nisi ligula. Mauris lobortis lacinia nunc vitae pellentesque. Quisque quis tincidunt nulla. Curabitur lacinia volutpat condimentum. Sed blandit molestie arcu eu bibendum. Cras vestibulum sollicitudin risus, ac ullamcorper massa consectetur at. Sed vulputate ipsum est, in faucibus nisi scelerisque eu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos."
