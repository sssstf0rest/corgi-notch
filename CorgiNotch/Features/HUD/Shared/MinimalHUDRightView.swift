//
//  MinimalHUDRightView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 11/03/25.
//

import SwiftUI

struct MinimalHUDRightView<T: HUDDefaultsProtocol>: View {

    @ObservedObject var notchViewModel: NotchViewModel
    @ObservedObject var defaults: T

    var hudModel: HUDPropertyModel?

    var body: some View {
        if let hud = hudModel, defaults.isEnabled, defaults.style == .minimal, !notchViewModel.isExpanded {
            MinimalHUDView(
                notchViewModel: notchViewModel,
                variant: .right
            ) {
                Text(
                    String(
                        format: "%02.0f",
                        hud.value * 100
                    )
                )
                .fixedSize(horizontal: true, vertical: false)
                .font(
                    .title2.weight(
                        .medium
                    )
                )
                .foregroundStyle(Color.white)
            }
        }
    }
}
