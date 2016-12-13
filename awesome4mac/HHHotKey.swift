//
//  HHHotKey.swift
//  awesome4mac
//
//  Created by shuoshichen on 15/12/26.
//  Copyright © 2015年 com.imhuihui. All rights reserved.
//

import Foundation
import Carbon

class HHHotKey {
    private static var __once: () = {
            HHHotKey.registerHandler()
        }()
    fileprivate let hotKey: UInt32
    fileprivate let block: () -> ()
    fileprivate var registered = true
    
    typealias action = () -> Void
    static var shortcuts = [UInt32:action]()
    
    fileprivate init(hotKeyID: UInt32, block: @escaping () -> ()) {
        self.hotKey = hotKeyID
        self.block = block
        HHHotKey.shortcuts[hotKey] = block
    }
    
    static func registerHandler() {
        var eventHandler: EventHandlerRef? = nil
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let hotkeyCallBack: EventHandlerUPP = { handlerRef, eventRef, ptr in
            var hotKeyID: EventHotKeyID = EventHotKeyID()
            GetEventParameter(eventRef, OSType(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            //call defined action based on hotKeyID
            HHHotKey.shortcuts[hotKeyID.id]!()
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(), hotkeyCallBack, 1, &eventType, nil, &eventHandler) == noErr
    }
    
    fileprivate static var token: Int = 0
    
    class func register(_ keyCode: UInt32, modifiers: UInt32, block: @escaping () -> (), id: UInt32) -> HHHotKey? {
        _ = HHHotKey.__once
        var hotKey: EventHotKeyRef? = nil
        let hotKeyID = EventHotKeyID(signature:OSType(10000), id: id)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), OptionBits(0), &hotKey)
        return HHHotKey(hotKeyID: id, block: block)
    }
    
}
