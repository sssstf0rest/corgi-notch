//
//  NowPlayingNavigationService.swift
//  CorgiNotch
//
//  Created by OpenAI Codex on 21/03/26.
//

import AppKit

@MainActor
final class NowPlayingNavigationService {

    static let shared = NowPlayingNavigationService()

    private let workspace = NSWorkspace.shared

    private init() {}

    func openSourceApplication(
        for nowPlayingModel: NowPlayingMediaModel
    ) {
        guard !isPlaceholder(nowPlayingModel) else {
            return
        }

        focusApplication(
            withBundleIdentifier: nowPlayingModel.appBundleIdentifier
        )
    }

    private func isPlaceholder(
        _ nowPlayingModel: NowPlayingMediaModel
    ) -> Bool {
        nowPlayingModel.appBundleIdentifier == NowPlayingMediaModel.placeholder.appBundleIdentifier
    }

    private func focusApplication(
        withBundleIdentifier bundleIdentifier: String
    ) {
        if let runningApplication = NSRunningApplication
            .runningApplications(
                withBundleIdentifier: bundleIdentifier
            )
            .first {
            runningApplication.activate(
                options: [
                    .activateAllWindows
                ]
            )
            return
        }

        guard let applicationURL = workspace.urlForApplication(
            withBundleIdentifier: bundleIdentifier
        ) else {
            return
        }

        workspace.openApplication(
            at: applicationURL,
            configuration: .init()
        )
    }
}
