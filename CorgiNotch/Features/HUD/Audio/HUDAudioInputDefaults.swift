//
//  HUDAudioInputDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

class HUDAudioInputDefaults: HUDDefaultsProtocol {
    
    internal static var keyPrefix: String = "HUD_Audio_Input_"
    
    static let shared = HUDAudioInputDefaults()
    
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
}
