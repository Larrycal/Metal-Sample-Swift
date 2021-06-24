//
//  Constant.swift
//  Utility
//
//  Created by 柳钰柯 on 2021/6/18.
//

import UIKit

public struct Constants {
    public static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    public static var indicatorSafeHeight: CGFloat {
        return isFullScreen ? 34:0
    }
    public static var isFullScreen: Bool {
        return !(UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0)
    }
    public static var onePixel: CGFloat {
        return 1/UIScreen.main.scale
    }
    public static var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    
    public static var userCacheDirectoryPath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    }
    public static var userCacheDirectoryURL: URL {
        return URL(fileURLWithPath: userCacheDirectoryPath)
    }
    public static var userTempDirectoryPath: String {
        return NSTemporaryDirectory()
    }
    public static var userTempDirectoryURL: URL {
        return URL(fileURLWithPath: userTempDirectoryPath)
    }
}
