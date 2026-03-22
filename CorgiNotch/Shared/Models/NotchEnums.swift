//
//  NotchEnums.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import Foundation

enum NotchHeightMode: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }

    case matchNotch = "Match_Notch"
    case matchMenuBar = "Match_Menu_Bar"
    case manual = "Manual"

    var displayName: String {
        switch self {
        case .matchNotch: return "Match Notch"
        case .matchMenuBar: return "Match Menu Bar"
        case .manual: return "Manual"
        }
    }
}
