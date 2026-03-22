//
//  NowPlayingDefaults.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 04/01/2026.
//

import SwiftUI

class NowPlayingDefaults: ObservableObject {
    
    static let shared = NowPlayingDefaults()
    
    private static var keyPrefix: String = "Expanded_Now_Playing_"
    
    private init() {}
    
    @AppStorage(keyPrefix + "AlbumArtCornerRadius") var albumArtCornerRadius: Double = 12.0 {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    @AppStorage(keyPrefix + "ShowArtist") var showArtist: Bool = true {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    @AppStorage(keyPrefix + "ShowAlbum") var showAlbum: Bool = true {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
    
    @AppStorage(keyPrefix + "ShowAppIcon") var showAppIcon: Bool = true {
        didSet {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }

}
