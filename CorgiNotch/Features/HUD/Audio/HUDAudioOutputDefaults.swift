//
//  HUDAudioOutputDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

class HUDAudioOutputDefaults: HUDDefaultsProtocol {
    
    internal static var keyPrefix: String = "HUD_Audio_Output_"
    
    static let shared = HUDAudioOutputDefaults()
    
    private init() {
        style = .minimal
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
        keyPrefix + "Step",
        defaultValue: 5.0
    )
    var step: Double {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
}
