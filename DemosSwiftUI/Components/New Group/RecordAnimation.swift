//
//  RecordAnimation.swift
//  RecordAnimation
//
//  Created by Admin on 30/08/2021.
//

import SwiftUI

struct RecordAnimation: GeometryEffect {
    var onChange: (CGFloat) -> Void = { _ in () }
    var animatableData: CGFloat = 0 {
        didSet {
            onChange(animatableData)
        }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        return .init()
    }
}
