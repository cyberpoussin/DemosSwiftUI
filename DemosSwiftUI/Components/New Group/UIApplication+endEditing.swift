//
//  UIApplication+endEditing.swift
//  UIApplication+endEditing
//
//  Created by Admin on 30/08/2021.
//

import UIKit
extension UIApplication {
    func endEditing(_ force: Bool) {
        windows
            .filter { $0.isKeyWindow }
            .first?
            .endEditing(force)
    }
}
