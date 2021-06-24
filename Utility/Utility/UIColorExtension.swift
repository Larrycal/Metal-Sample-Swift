//
//  UIColorExtension.swift
//  Utility
//
//  Created by 柳钰柯 on 2021/6/18.
//

import Foundation
import UIKit
import MetalKit

public extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1) {
        var newHexString = hexString
        newHexString = newHexString.replacingOccurrences(of: "#", with: "0x")
        let hexValue = Int(strtoul(newHexString, nil, 0))
        self.init(hexValue:hexValue,alpha:alpha)
    }
    
    convenience init(hexValue: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hexValue & 0xFF0000) >> 16)/255.0, green: CGFloat((hexValue & 0xFF00) >> 8)/255.0, blue: CGFloat(hexValue & 0xFF)/255.0, alpha: alpha)
    }
    
    var metalColor: MTLClearColor {
        var red:CGFloat = 1
        var green:CGFloat = 1
        var blue:CGFloat = 1
        var alpha:CGFloat = 1
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
}
