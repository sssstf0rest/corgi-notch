//
//  AppDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import Foundation

class AppDefaults: ObservableObject {
    
    private static var keyPrefix: String = "App_"
    
    static let shared = AppDefaults()
    
    private init() {}
    
    @PrimitiveUserDefault(
        keyPrefix + "StatusIconShown",
        defaultValue: true
    )
    var showMenuIcon: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "DisableSystemHUD",
        defaultValue: true
    )
    var disableSystemHUD: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
}
