//
//  NotchDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import Foundation

class NotchDefaults: ObservableObject {
    
    private static var keyPrefix: String = "Notch_"
    
    static let shared = NotchDefaults()
    
    private init() {
        var currentOrder = expandedItemsOrder
        let allItems = ExpandedNotchItem.allCases
        
        let missingItems = allItems.filter { !currentOrder.contains($0) }
        
        if !missingItems.isEmpty {
            currentOrder.append(contentsOf: missingItems)
            expandedItemsOrder = currentOrder
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "HideOnFullScreen",
        defaultValue: true
    )
    var hideOnFullScreen: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @CodableUserDefault(
        keyPrefix + "NotchDisplayVisibility",
        defaultValue: NotchDisplayVisibility.notchedDisplayOnly
    )
    var notchDisplayVisibility: NotchDisplayVisibility {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @CodableUserDefault(
        keyPrefix + "ShownOnDisplay",
        defaultValue: [:]
    )
    var shownOnDisplay: [String: Bool] {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "ShownOnLockScreen",
        defaultValue: true
    )
    var shownOnLockScreen: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "resetViewOnCollapse",
        defaultValue: true
    )
    var resetViewOnCollapse: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @CodableUserDefault(
        keyPrefix + "HeightMode",
        defaultValue: NotchHeightMode.matchNotch
    )
    var heightMode: NotchHeightMode {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "GlassEffect",
        defaultValue: true
    )
    var applyGlassEffect: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "ExpandOnHover",
        defaultValue: true
    )
    var expandOnHover: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }

    @PrimitiveUserDefault(
        keyPrefix + "HapticFeedback",
        defaultValue: true
    )
    var hapticFeedback: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @PrimitiveUserDefault(
        keyPrefix + "ExpandedNotchShowDividers",
        defaultValue: false
    )
    var showDividers: Bool {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @CodableUserDefault(
        keyPrefix + "ExpandedNotchItems",
        defaultValue: [
            ExpandedNotchItem.nowPlaying
        ]
    )
    var expandedNotchItems: [ExpandedNotchItem] {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @CodableUserDefault(
        keyPrefix + "ExpandedItemsOrder",
        defaultValue: ExpandedNotchItem.allCases
    )
    var expandedItemsOrder: [ExpandedNotchItem] {
        didSet {
            self.objectWillChange.send()
        }
    }
}
