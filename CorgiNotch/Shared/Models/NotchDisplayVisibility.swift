//
//  NotchDisplayVisibility.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 28/04/25.
//

import Foundation

enum NotchDisplayVisibility: String, CaseIterable, Codable, Identifiable {
    var id: String {
        self.rawValue
    }

    case allDisplays = "AllDisplays"
    case notchedDisplayOnly = "NotchedDisplayOnly"
    case custom = "Custom"

    var displayName: String {
        switch self {
        case .allDisplays:
            return "All Displays"
        case .notchedDisplayOnly:
            return "Notched Displays Only"
        case .custom:
            return "Custom"
        }
    }
}
