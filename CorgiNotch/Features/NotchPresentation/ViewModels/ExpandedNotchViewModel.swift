//
//  ExpandedNotchViewModel.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 26/03/25.
//

import SwiftUI

class ExpandedNotchViewModel: ObservableObject {

    @Published var nowPlayingMedia: NowPlayingMediaModel?

    init() {
        self.startListeners()

        self.nowPlayingMedia = NowPlaying.shared.nowPlayingModel
    }
    
    deinit {
        self.stopListeners()
    }
    
    func startListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNowPlayingMediaChanges),
            name: NSNotification.Name.NowPlayingInfo,
            object: nil
        )
    }
    
    func stopListeners() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleNowPlayingMediaChanges() {
        guard let nowPlayingMedia = NowPlaying.shared.nowPlayingModel else {
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.nowPlayingMedia = nowPlayingMedia
            }
        }
    }
    
}
