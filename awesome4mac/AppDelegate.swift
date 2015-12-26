//
//  AppDelegate.swift
//  awesome4mac
//
//  Created by shuoshichen on 15/12/25.
//  Copyright © 2015年 com.imhuihui. All rights reserved.
//

import Cocoa
import AppKit
import Carbon

struct HHAttributeConstants {
    static let Position = "AXPosition"
    static let Size = "AXSize"
    static let Title = "AXTitle"
    static let Windows = "AXWindows"
}

class MyObserver: NSObject, NSApplicationDelegate
{
    var currentApp: NSRunningApplication!
    var currentPosition: Int!
    var currentCmd: Int!
    
    var currentWindow: AXUIElement! {
        let appRef = AXUIElementCreateApplication((currentApp?.processIdentifier)!);
        return AccessibilityWrapper.windowsInApp(appRef.takeRetainedValue())!
    }
    
    override init() {
        super.init()
        // app listeners
        currentCmd = 0
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: "currentApp:", name: NSWorkspaceDidActivateApplicationNotification, object: nil)
    }
    
    func currentApp(notification: NSNotification!) {
        let app = notification.userInfo![NSWorkspaceApplicationKey] as? NSRunningApplication
        if currentApp == nil || app?.bundleIdentifier != "com.imhuihui.awesome4mac" {
            currentApp = app
            print(currentApp)
        }
    }
    
    func moveToNextWindow() {
        let nextScreenRect = AccessibilityWrapper.getNextScreen(currentWindow).frame
        let nextRect = nextScreenRect.origin
        let nextSize = nextScreenRect.size
        
        let currentScreenRect = AccessibilityWrapper.getCurrentScreen(currentWindow).frame
        let currentSize = currentScreenRect.size
        
        let size = AccessibilityWrapper.size(currentWindow)
        let newSize = CGSize(width: size.width * nextSize.width / currentSize.width, height: size.height * nextSize.height / currentSize.height)
        AccessibilityWrapper.setNewPositionSize(currentWindow, newPosition: nextRect, newSize: newSize)
    }
    
    func changeWindowSize(cmd: Int) {
        let currentScreenRect = AccessibilityWrapper.getCurrentScreen(currentWindow).frame
        let screenOrigin = currentScreenRect.origin
        let screenSize = currentScreenRect.size
        if currentCmd != cmd {
            currentPosition = 0
            currentCmd = cmd
        }
        switch (cmd) {
            case 1:
                AccessibilityWrapper.setNewPositionSize(currentWindow, newPosition: CGPoint(x: screenOrigin.x, y: screenOrigin.y), newSize: screenSize)
            case 2:
                currentPosition = currentPosition % 2
                AccessibilityWrapper.setNewPositionSize(currentWindow, newPosition: CGPoint(x: currentPosition == 0 ? screenOrigin.x : screenOrigin.x + screenSize.width/2, y: 0), newSize: CGSize(width: screenSize.width/2, height: screenSize.height))
                currentPosition = currentPosition + 1
            case 3:
                currentPosition = currentPosition % 2
                AccessibilityWrapper.setNewPositionSize(currentWindow, newPosition: CGPoint(x: screenOrigin.x, y: currentPosition == 0 ? 0 : screenSize.height/2), newSize: CGSize(width: screenSize.width, height: screenSize.height/2))
                currentPosition = currentPosition + 1
            case 4:
                currentPosition = currentPosition % 4
                let x = currentPosition % 2 == 0 ? screenOrigin.x : screenOrigin.x + screenSize.width/2
                let y = currentPosition < 2 ? 0 : screenSize.height/2
                AccessibilityWrapper.setNewPositionSize(currentWindow, newPosition: CGPoint(x: x, y: y), newSize: CGSize(width: screenSize.width/2, height: screenSize.height/2))
                currentPosition = currentPosition + 1
            default:
                return
        }
    }
   
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func acquireAXPrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        if accessEnabled != Bool(1) {
            print("You need to enable the keylogger in the System Prefrences")
        }
        return accessEnabled == Bool(1)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        //ask for accessibility privilege
        acquireAXPrivileges()
        
        //register application delegate to detect focused window
        let application = NSApplication.sharedApplication()
        let applicationDelegate = MyObserver()
        application.delegate = applicationDelegate
        
        HHHotKey.register(UInt32(kVK_ANSI_0), modifiers: UInt32(cmdKey|optionKey), block: {
            applicationDelegate.moveToNextWindow()
            }, id: 0)
        
        HHHotKey.register(UInt32(kVK_ANSI_1), modifiers: UInt32(cmdKey|optionKey), block: {
            applicationDelegate.changeWindowSize(1)
            }, id: 1)
        
        HHHotKey.register(UInt32(kVK_ANSI_2), modifiers: UInt32(cmdKey|optionKey), block: {
            applicationDelegate.changeWindowSize(2)
        }, id: 2)
        
        HHHotKey.register(UInt32(kVK_ANSI_3), modifiers: UInt32(cmdKey|optionKey), block: {
            applicationDelegate.changeWindowSize(3)
        }, id: 3)
        
        HHHotKey.register(UInt32(kVK_ANSI_4), modifiers: UInt32(cmdKey|optionKey), block: {
            applicationDelegate.changeWindowSize(4)
            }, id: 4)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

