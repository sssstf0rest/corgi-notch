//
//  ExpandedNotchItem.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 28/04/25.
//


enum ExpandedNotchItem: String, CaseIterable, Codable, Identifiable {
    var id: String {
        self.rawValue
    }

    case nowPlaying = "NowPlaying"

    var displayName: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        }
    }

    var imageSystemName: String {
        switch self {
        case .nowPlaying:
            return "music.note"
        }
    }
}
