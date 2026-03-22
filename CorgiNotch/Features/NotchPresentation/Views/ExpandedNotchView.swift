//
//  ExpandedNotchView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 27/03/25.
//

import SwiftUI

struct ExpandedNotchView: View {

    var namespace: Namespace.ID

    @Namespace private var nilNamespace

    @StateObject private var notchDefaults = NotchDefaults.shared

    @ObservedObject var notchViewModel: NotchViewModel
    @ObservedObject var expandedNotchViewModel: ExpandedNotchViewModel

    var collapsedNotchView: CollapsedNotchView

    var body: some View {
        VStack {
            HStack(
                alignment: .top,
                spacing: 4
            ) {
                collapsedNotchView
                    .opacity(0)
                    .disabled(true)

                SettingsControlView(
                    notchViewModel: notchViewModel
                )
                .padding(.leading, 8)
            }
            .zIndex(5)

            NotchHomeView(
                namespace: namespace,
                notchViewModel: notchViewModel,
                expandedNotchViewModel: expandedNotchViewModel,
                collapsedNotchView: collapsedNotchView
            )
        }
        .padding(
            .init(
                top: 0,
                leading: 8 + notchViewModel.extraNotchPadSize.width / 2,
                bottom: 8,
                trailing: 8 + notchViewModel.extraNotchPadSize.width / 2
            )
        )
        .scaleEffect(
            notchViewModel.isExpanded ? 1 : 0.3,
            anchor: .top
        )
        .frame(
            width: notchViewModel.isExpanded ? nil : 0,
            height: notchViewModel.isExpanded ? nil : 0
        )
        .opacity(notchViewModel.isExpanded ? 1 : 0)
    }
}
