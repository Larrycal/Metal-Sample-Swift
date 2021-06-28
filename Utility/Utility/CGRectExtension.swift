//
//  CGRectExtension.swift
//  Utility
//
//  Created by 柳钰柯 on 2021/6/25.
//

import Foundation
import UIKit

public extension CGSize {
    init(width: Int, height: Int) {
        self.init(width: CGFloat(width), height: CGFloat(height))
    }
    
    var aspect: CGFloat {
        return width / height
    }
}
