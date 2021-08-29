//
//  String+random.swift
//  DemosSwiftUI
//
//  Created by Admin on 29/08/2021.
//

import Foundation
extension String {
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}
