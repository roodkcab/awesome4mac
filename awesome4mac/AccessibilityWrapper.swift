//
//  AccessibilityWrapper.swift
//  awesome4mac
//
//  Created by shuoshichen on 15/12/25.
//  Copyright © 2015年 com.imhuihui. All rights reserved.
//

import Cocoa
import Foundation

// A wrapper around C Accessibility APIs that TextSwitcher uses.
class AccessibilityWrapper {
    
    class func windowsInApp(app: AXUIElementRef) -> AXUIElement! {
        let window : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        if AXUIElementCopyAttributeValue(app, "AXFocusedWindow", window) == AXError.Success {
            return window.memory as! AXUIElement
        }
        return nil
    }
    
    class func getCurrentScreen(window: AXUIElement) -> NSScreen {
        let origin = AccessibilityWrapper.position(window)
        let size = AccessibilityWrapper.size(window)
        let currentWindowFrame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        for screen in NSScreen.screens()! {
            let intersection = NSIntersectionRect(screen.frame, currentWindowFrame)
            if intersection.width > 0 {
                return screen
            }
        }
        return NSScreen.mainScreen()!
    }
    
    class func getNextScreen(window: AXUIElement) -> NSScreen {
        if NSScreen.screens()?.count < 2 {
            return NSScreen.mainScreen()!
        } else {
            let origin = AccessibilityWrapper.position(window)
            let size = AccessibilityWrapper.size(window)
            let currentWindowFrame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
            let screens = NSScreen.screens()!
            for i in Range(start: 0, end: screens.count) {
                let intersection = NSIntersectionRect(screens[i].frame, currentWindowFrame)
                if intersection.width > 0 {
                    return screens[(i + 1) % screens.count]
                }
            }
        }
        return NSScreen.mainScreen()!
    }
    
    class func size(window: AXUIElementRef) -> CGSize {
        var out:AnyObject? = nil
        let axerr = AXUIElementCopyAttributeValue( window, HHAttributeConstants.Size, &out )
        if AXError.Success != axerr || nil == out {
            return CGSize()
        }
        let value = out as! AXValue
        var sz = CGSize()
        AXValueGetValue(value, AXValueType.CGSize, &sz)
        return sz
    }
    
    class func position(window: AXUIElementRef) -> CGPoint {
        var out:AnyObject? = nil
        let axerr = AXUIElementCopyAttributeValue( window, HHAttributeConstants.Position, &out )
        if AXError.Success != axerr || nil == out {
            return CGPoint()
        }
        let value = out as! AXValue
        var pt = CGPoint()
        AXValueGetValue(value, AXValueType.CGPoint, &pt)
        return pt
    }
    
    class func setNewPositionSize(window: AXUIElementRef, newPosition: CGPoint, newSize: CGSize) {
        var pt = newPosition
        let newPt: AXValue = AXValueCreate(AXValueType.CGPoint, &pt)!.takeRetainedValue()
        AXUIElementSetAttributeValue(window, HHAttributeConstants.Position, newPt)
        var sz = newSize
        let newSz: AXValue = AXValueCreate(AXValueType.CGSize, &sz)!.takeRetainedValue()
        AXUIElementSetAttributeValue(window, HHAttributeConstants.Size, newSz)
    }
    
}