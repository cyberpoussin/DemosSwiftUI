//
//  AnimatorScroll.swift
//  AnimatorScroll
//
//  Created by Admin on 30/08/2021.
//

import UIKit

class AnimatorScroll {
    static let shared = AnimatorScroll()
    var animator:UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1.5, curve: .linear){
    }
    private init() { }
}


// POUR AVOIR RESPONSE ET DAMP
// extension UISpringTimingParameters {
//    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
//        let stiffness = pow(2 * .pi / response, 2)
//        let damp = 4 * .pi * damping / response
//        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
//    }
// }
