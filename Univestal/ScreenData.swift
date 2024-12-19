//
//  ScreenData.swift
//  Univestal
//
//  Created by Nathan Egbuna on 12/18/24.
//

import Foundation
import UIKit

extension UIScreen {
    static var deviceWidth: CGFloat {
        main.bounds.width
    }
    
    static var deviceHeight: CGFloat {
        main.bounds.height
    }
    
    // Helper for relative scaling
    static func relativeWidth(_ percentage: CGFloat) -> CGFloat {
        self.deviceWidth * (percentage / 100)
    }
    
    static func relativeHeight(_ percentage: CGFloat) -> CGFloat {
        self.deviceHeight * (percentage / 100)
    }
}
