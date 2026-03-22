//
//  HUDAudioSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct HUDAudioSettingsView: View {
    
    @StateObject private var viewModel = HUDAudioSettingsViewModel()
    
    var body: some View {
        Form {
            Section {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Shows input and output volume changes",
                    icon: CorgiNotch.Assets.icSpeakerWave2,
                    color: CorgiNotch.Colors.output
                ) {
                    Toggle("", isOn: Binding(
                        get: { viewModel.isAudioHUDEnabled },
                        set: { viewModel.setAudioHUDEnabled($0) }
                    ))
                }
                
                HStack(spacing: 16) {
                    SettingsIcon(icon: CorgiNotch.Assets.icChartBar, color: CorgiNotch.Colors.stepSize)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Step Size")
                                .font(.title3)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(viewModel.localVolumeStep))%")
                                .font(.body)
                                .monospacedDigit()
                                .bold()
                        }
                        
                        Slider(
                            value: $viewModel.localVolumeStep,
                            in: 1...10,
                            step: 1
                        )
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Audio")
    }
}

#Preview {
    HUDAudioSettingsView()
}
