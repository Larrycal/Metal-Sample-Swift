//
//  Tool.swift
//  Utility
//
//  Created by 柳钰柯 on 2021/6/18.
//

import Foundation

@discardableResult
public func delay(_ time:Double,handler:@escaping (()->Void)) -> DispatchWorkItem? {
    var dispatchItem: DispatchWorkItem?
    dispatchItem = DispatchWorkItem {
        if dispatchItem?.isCancelled ?? true {
            dispatchItem = nil
            return
        }
        handler()
        dispatchItem = nil
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: dispatchItem!)
    return dispatchItem
}
