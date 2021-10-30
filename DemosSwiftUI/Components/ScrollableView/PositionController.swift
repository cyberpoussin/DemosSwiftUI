//
//  PositionSheet.swift
//  FoodLyon
//
//  Created by foxy on 24/03/2020.
//  Copyright © 2020 AdrienSimon. All rights reserved.
//

import SwiftUI
import Combine

var springAnimator = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: CGVector(dx: 0.3, dy: 0.3)))


final class PositionController: ObservableObject {
    var sheetParameters = SheetParameters()    
    var statusBarHeight: CGFloat {
        (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
    }
    var topLimit: CGFloat {
        sheetParameters.topPositionHeight
    }
    var middleLimit: CGFloat {
        sheetParameters.middlePositionHeight
    }
    
    var middleBottomAverage: CGFloat {
        (middleLimit + bottomLimit)/2.0
    }
    
    var middleTopAverage: CGFloat {
        (middleLimit + topLimit)/2.0
    }
    
    var bottomLimit: CGFloat {
        sheetParameters.bottomPositionHeight
    }
    var sheetWidth: CGFloat {
        sheetParameters.sheetWidth
    }
    var sheetHorizontalPadding: CGFloat {
        sheetParameters.sheetHorizontalPadding
    }
    
    @Environment(\.verticalSizeClass) var sizeClass

    @Published var offset: CGPoint
    @Published var oldOffset: CGPoint
    
    init(sheetParameters: SheetParameters = SheetParameters()) {
        self.sheetParameters = sheetParameters
        offset = CGPoint(x: sheetParameters.sheetWidth/2 - UIScreen.main.bounds.width/2 + sheetParameters.sheetHorizontalPadding, y: sheetParameters.bottomPositionHeight)
        oldOffset = CGPoint(x: sheetParameters.sheetWidth/2 - UIScreen.main.bounds.width/2 + sheetParameters.sheetHorizontalPadding, y: sheetParameters.bottomPositionHeight)
        totalDrag = CGPoint(x: 0, y: sheetParameters.bottomPositionHeight)
    }
    
    var decalLeft: CGFloat {
        if sheetWidth < UIScreen.main.bounds.width {
            return  sheetWidth/2 - UIScreen.main.bounds.width/2 + sheetHorizontalPadding
        }
        return 0
    }
    
    func reinit() {
        offset = CGPoint(x: decalLeft, y: bottomLimit)
        oldOffset = CGPoint(x: decalLeft, y: bottomLimit)
        isScrollable = false
        velocity = CGPoint(x: 0, y: 0)
        isAnimated = false
        headerDragged = false
        stop = CGPoint(x:0, y:0) // where we tap and stop the animation
        isScrolled = false
    }
    
    func deploy () {
        print("on remonte")
        if decalLeft < 0 {
            offset = CGPoint(x: decalLeft, y: topLimit)
            oldOffset = CGPoint(x: decalLeft, y: topLimit)
        } else {
        offset = CGPoint(x: decalLeft, y: middleLimit)
        oldOffset = CGPoint(x: decalLeft, y: middleLimit)
        }
    }
    
    
    @Published var isScrollable: Bool = false
    var velocity = CGPoint(x: 0, y: 0)
    var isAnimated: Bool = false
    var headerDragged: Bool = false
    var stop = CGPoint(x:0, y:0) // where we tap and stop the animation

    var isScrolled: Bool = false {
        didSet {
            
            // si en fait rien n'a changé, on break
            if oldValue == isScrolled {
                return
            }
            
            // si la sheet est en haut et qu'on est autorisé à faire défiler le texte et que l'utilisateur fait effectivement un mouvement depuis le bas : on ne déplace pas la sheet (mais son contenu)
            if isScrollable && velocity.y < 0 {
                return
            }
            
            /* MARK: onDragEnded
             Quand on lâche le drag
             On replace la sheet au bon endroit (Top, Middle ou Bottom Limit)
             */
            if !isScrolled {
                
                var scotch: CGFloat = bottomLimit // the 'y' where we are going to place the sheet
                
                var deceleration = UIScrollView().decelerationRate.rawValue
                deceleration = deceleration/(1 - deceleration)
                // ici mettre une velocity plus fine
                let projection = totalDrag.y + (velocity.y/2000) * deceleration
                                
                // if the sheet will bounce (depends of velocity)
                var bounce: Bool = true
                
                if velocity.y < 0 && totalDrag.y == topLimit {
                    return
                }
                
                if totalDrag.y >= middleLimit {
                    // on lache en dessous du milieu
                    if velocity.y <= 0 {
                        // on vient du bas
                        switch projection {
                        case (-1 * .infinity) ..< middleLimit :
                            bounce = true
                            scotch = middleLimit
                        case middleLimit ..< middleBottomAverage:
                            bounce = false
                            scotch = middleLimit
                        case middleBottomAverage ..< .infinity:
                            bounce = false
                            scotch = bottomLimit
                        default: break
                        }
                    }
                    
                    
                    if velocity.y > 0 {
                        //on vient du haut
                        switch projection {
                        case middleLimit ..< middleBottomAverage:
                            bounce = false
                            scotch = middleLimit
                        case middleBottomAverage ..< bottomLimit :
                            bounce = false
                            scotch = bottomLimit
                        case bottomLimit ..< .infinity:
                            bounce = true
                            scotch = bottomLimit
                        default: break
                        }
                    }
                    //on lâche au dessus du milieu
                } else if totalDrag.y < middleLimit {
                    if velocity.y <= 0 {
                        // on vient du bas
                        switch projection {
                        case ..<topLimit :
                            bounce = true
                            scotch = topLimit
                        case topLimit ..< middleTopAverage:
                            bounce = false
                            scotch = topLimit
                        case middleTopAverage ..< middleLimit:
                            bounce = false
                            scotch = middleLimit
                        default: break
                        }
                    }
                    if velocity.y > 0 {
                        //on vient du haut
                        switch projection {
                        case (-1 * .infinity) ..< middleTopAverage :
                            bounce = false
                            scotch = topLimit
                        case middleTopAverage ..< middleLimit :
                            bounce = false
                            scotch = middleLimit
                        case middleLimit ..< .infinity:
                            bounce = true
                            scotch = middleLimit
                        default: break
                        }
                    }
                }
                
                // MARK: Animation after dragEnded
                // on applique le "scotch" défini plus haut (en fonction de la vélocité, de l'endroit où on a lâché, etc.) en appliquant une animation (selon le "bounce")
                if totalDrag.y != scotch {
                    //isAnimated = true
                    var response = 0.27
//                    if abs(velocity.y) > 500 {
//                        response = 0.2
//                    } else {
//                        response = 0.3
//                    }
                    response = Double((1/(log10(1 + abs(velocity.y))/log10(5000))) * 0.3)
                    print("lancé à \(velocity.y) avec une réponse de \(response)")
                    if response > 0.4 || response <= 0 {
                        response = 0.4
                    }
                    if bounce {
                        withAnimation(.spring(response: response, dampingFraction: 0.63, blendDuration: 1)) {
                            totalDrag.y = scotch
                            oldOffset.y = scotch
                            print("je suis animé ! \(isAnimated)")
                        }
                        velocity.y = 0

                    }
                    else {
                        withAnimation(.spring(response: response, dampingFraction: 1, blendDuration: 1)) {
                            totalDrag.y = scotch
                            oldOffset.y = scotch
                            print("je suis animé ! \(isAnimated)")
                        }
                        velocity.y = 0
                    }
                }
                // ATTENTION : si une animation était déjà en cours, et qu'on l'attrappe au vol
            } else if isAnimated {
                print("arretez tout ! \(stop.y)")
                
                withAnimation(.linear(duration: 0)) {
                    totalDrag.y = stop.y
                    oldOffset.y = stop.y
                    //isAnimated = false
                    //isScrolled = false
                }
            }
        }
    }
    
    
    var totalDrag: CGPoint {
        didSet {
            
            // Si en draggant on tappe le haut
            if totalDrag.y <= topLimit {
                // si on dragge le 'centre' de la sheet, on bloque en haut (puisque c'est le contenu à partir de là qui va être scrollé)
                if !headerDragged {
                    offset.y = topLimit
                } else {
                // si on dragge le titre, ok on bloque pas on peut monter encore et encore
                    if isAnimated {
                        offset.y = totalDrag.y
                    } else {
                        //withAnimation(.linear(duration: 0)) {
                        offset.y = totalDrag.y
                        //}
                    }
                }
                if !headerDragged && isScrolled {
                    isScrollable = true
                }
                if offset.y < topLimit {
                    isScrollable = false
                }
            } else {
                isScrollable = false
                if isAnimated {
                    offset.y = totalDrag.y
                } else {
                    //withAnimation(.linear(duration: 0)) {
                    offset.y = totalDrag.y
                    //}
                }
            }
            if isScrolled {
                isAnimated = false
            }
        }
    }
}

