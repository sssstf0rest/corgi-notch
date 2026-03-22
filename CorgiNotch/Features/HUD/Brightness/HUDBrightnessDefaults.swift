//
//  HUDBrightnessDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

class HUDBrightnessDefaults: HUDDefaultsProtocol {
    
    internal static var keyPrefix: String = "HUD_Brightness_"
    
    static let shared = HUDBrightnessDefaults()
    
    private init() {
        style = .minimal
        showAutoBrightnessChanges = false
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "Enabled",
        defaultValue: true
    )
    var isEnabled: Bool {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    @CodableUserDefault(
        keyPrefix + "Style",
        defaultValue: HUDStyle.minimal
    )
    var style: HUDStyle {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "ShowAutoBrightnessChanges",
        defaultValue: false
    )
    var showAutoBrightnessChanges: Bool {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "Step",
        defaultValue: 0.05
    )
    var step: Double {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
}
