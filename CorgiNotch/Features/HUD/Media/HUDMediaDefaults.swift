//
//  HUDMediaDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

class HUDMediaDefaults: HUDDefaultsProtocol {
    
    internal static var keyPrefix: String = "HUD_Media_"
    
    static let shared = HUDMediaDefaults()
    
    private init() {}
    
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
