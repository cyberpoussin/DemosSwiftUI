//
//  SheetParameters.swift
//  SheetParameters
//
//  Created by Admin on 30/08/2021.
//

import SwiftUI

struct SheetParameters {
    let portraitTopPosition: (bigIphone: CGFloat, smallIphone: CGFloat, other: CGFloat) = (bigIphone: 150, smallIphone: 100, other: 100)
    let landscapeTopPosition: (bigIphone: CGFloat, smallIphone: CGFloat, other: CGFloat) = (bigIphone: 100, smallIphone: 50, other: 100)
    let bottomPosition: CGFloat = 50
    let middlePosition: CGFloat = 150
    let sheetHorizontalPadding: CGFloat = 0
    var bottomPositionHeight: CGFloat {
        return UIScreen.main.bounds.height - bottomPosition
    }
    var middlePositionHeight: CGFloat {
        if DeviceManager.isAnIphoneOrUnknown && DeviceManager.orientation == .landscape {
            return topPositionHeight
        }
        return UIScreen.main.bounds.height/2 + middlePosition
    }
    var topPositionHeight: CGFloat {
        if DeviceManager.orientation == .landscape {
            switch DeviceManager.device {
            case .iPhoneX, .iPhoneXmax: return landscapeTopPosition.bigIphone
            case .iPhone8: return landscapeTopPosition.smallIphone
            default: return landscapeTopPosition.other
            }
        }
        switch DeviceManager.device {
        case .iPhoneX, .iPhoneXmax: return portraitTopPosition.bigIphone
        case .iPhone8: return portraitTopPosition.smallIphone
        default: return portraitTopPosition.other
        }
    }
    
    var sheetWidth: CGFloat {
        if DeviceManager.isAnIphoneOrUnknown && DeviceManager.orientation == .portrait {
            return UIScreen.main.bounds.width - sheetHorizontalPadding * 2
        } else {
           return 375
        }
    }

}
