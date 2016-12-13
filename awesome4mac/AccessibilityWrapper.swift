//
//  AccessibilityWrapper.swift
//  awesome4mac
//
//  Created by shuoshichen on 15/12/25.
//  Copyright © 2015年 com.imhuihui. All rights reserved.
//

import Cocoa
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


// A wrapper around C Accessibility APIs that TextSwitcher uses.
class AccessibilityWrapper {
    
    class func windowsInApp(_ app: AXUIElement) -> AXUIElement! {
        let window : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        if AXUIElementCopyAttributeValue(app, "AXFocusedWindow" as CFString, window) == AXError.success {
            return window.pointee as! AXUIElement
        }
        return nil
    }
    
    class func getCurrentScreen(_ window: AXUIElement) -> NSScreen {
        let origin = AccessibilityWrapper.position(window)
        let size = AccessibilityWrapper.size(window)
        let currentWindowFrame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        for screen in NSScreen.screens()! {
            let intersection = NSIntersectionRect(screen.frame, currentWindowFrame)
            if intersection.width > 0 {
                return screen
            }
        }
        return NSScreen.main()!
    }
    
    class func getNextScreen(_ window: AXUIElement) -> NSScreen {
        if NSScreen.screens()?.count < 2 {
            return NSScreen.main()!
        } else {
            let origin = AccessibilityWrapper.position(window)
            let size = AccessibilityWrapper.size(window)
            let currentWindowFrame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
            let screens = NSScreen.screens()!
            for i in (0 ..< screens.count) {
                let intersection = NSIntersectionRect(screens[i].frame, currentWindowFrame)
                if intersection.width > 0 {
                    return screens[(i + 1) % screens.count]
                }
            }
        }
        return NSScreen.main()!
    }
    
    class func size(_ window: AXUIElement) -> CGSize {
        var out:AnyObject? = nil
        let axerr = AXUIElementCopyAttributeValue( window, HHAttributeConstants.Size as CFString, &out )
        if AXError.success != axerr || nil == out {
            return CGSize()
        }
        let value = out as! AXValue
        var sz = CGSize()
        AXValueGetValue(value, AXValueType.cgSize, &sz)
        return sz
    }
    
    class func position(_ window: AXUIElement) -> CGPoint {
        var out:AnyObject? = nil
        let axerr = AXUIElementCopyAttributeValue( window, HHAttributeConstants.Position as CFString, &out )
        if AXError.success != axerr || nil == out {
            return CGPoint()
        }
        let value = out as! AXValue
        var pt = CGPoint()
        AXValueGetValue(value, AXValueType.cgPoint, &pt)
        return pt
    }
    
    class func setNewPositionSize(_ window: AXUIElement, newPosition: CGPoint, newSize: CGSize) {
        var pt = newPosition
        let newPt: AXValue = AXValueCreate(AXValueType.cgPoint, &pt)!
        AXUIElementSetAttributeValue(window, HHAttributeConstants.Position as CFString, newPt)
        var sz = newSize
        let newSz: AXValue = AXValueCreate(AXValueType.cgSize, &sz)!
        AXUIElementSetAttributeValue(window, HHAttributeConstants.Size as CFString, newSz)
    }
    
}
