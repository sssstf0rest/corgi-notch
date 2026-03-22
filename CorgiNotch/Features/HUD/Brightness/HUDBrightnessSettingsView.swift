//
//  HUDBrightnessSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct HUDBrightnessSettingsView: View {
    
    @StateObject private var viewModel = HUDBrightnessSettingsViewModel()
    
    var body: some View {
        Form {
            Section {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Shows brightness changes",
                    icon: CorgiNotch.Assets.icBrightnessFill,
                    color: CorgiNotch.Colors.brightness
                ) {
                    Toggle("", isOn: $viewModel.defaults.isEnabled)
                }
                
                HStack(spacing: 16) {
                    SettingsIcon(icon: CorgiNotch.Assets.icChartBar, color: CorgiNotch.Colors.stepSize)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Step Size")
                                .font(.title3)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(viewModel.localStep * 100))%")
                                .font(.body)
                                .monospacedDigit()
                                .bold()
                        }
                        
                        Slider(
                            value: $viewModel.localStep,
                            in: 0.01...0.10,
                            step: 0.01
                        )
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Brightness")
    }
}

#Preview {
    HUDBrightnessSettingsView()
}
