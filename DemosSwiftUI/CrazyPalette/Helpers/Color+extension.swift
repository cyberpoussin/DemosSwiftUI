//
//  Color+extension.swift
//  NewFlowerApp
//
//  Created by Admin on 11/02/2021.
//

import SwiftUI
extension Color {
    
    init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000FF) / 255

                    self.init(UIColor(red: r, green: g, blue: b, alpha: a))
                    return
                }
            }
        }

        return nil
    }
    
    var uiColor: UIColor { .init(self) }
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (r, g, b, a) : nil
    }

    var hexaRGB: String? {
        guard let rgba = rgba else { return nil }
        return String(format: "#%02x%02x%02x",
                      Int(rgba.red * 255),
                      Int(rgba.green * 255),
                      Int(rgba.blue * 255))
    }

    var hexaRGBA: String? {
        guard let rgba = rgba else { return nil }
        return String(format: "#%02x%02x%02x%02x",
                      Int(rgba.red * 255),
                      Int(rgba.green * 255),
                      Int(rgba.blue * 255),
                      Int(rgba.alpha * 255))
    }
}
