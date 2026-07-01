//
//  ServiceStatus.swift
//  NightscoutServiceKitUI
//
//  Created by Pete Schwamb on 9/30/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI
import NightscoutServiceKit

struct ServiceStatusView: View, HorizontalSizeClassOverride {
    @Environment(\.dismissAction) private var dismiss

    @ObservedObject var viewModel: ServiceStatusViewModel
    @ObservedObject var otpViewModel: OTPViewModel
    @State private var selectedItem: String?
    @State private var secondaryUrl = ""
    @State private var secondaryApiSecret = ""
    @State private var changeSecondaryApiSecret = false
    var body: some View {
        VStack {
            Text("Nightscout")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image(frameworkImage: "nightscout", decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
            

            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("Primary Nightscout")
                        .font(.headline)
                        .padding()
                }
                Divider()
                HStack {
                    Text("URL")
                    Spacer()
                    Text(viewModel.urlString)
                }
                .padding()
                Divider()
                HStack {
                    Text("Status")
                    Spacer()
                    Text(String(describing: viewModel.status))
                }
                .padding()
                Divider()
                NavigationLink(destination: OTPSelectionView(otpViewModel: otpViewModel), tag: "otp-view", selection: $selectedItem) {
                    HStack {
                        Text("One-Time Password")
                        Spacer()
                        Text(otpViewModel.otpCode)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }.foregroundColor(Color.primary)
                .padding()
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Secondary Nightscout")
                        .font(.headline)

                    TextField("Secondary URL", text: $secondaryUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(5.0)

                    if viewModel.secondaryStatusString == "Configured" && !changeSecondaryApiSecret {
                        HStack {
                            Text("Secondary API Secret")
                            Spacer()
                            Text("********")
                                .foregroundColor(.secondary)
                            Button("Change") {
                                changeSecondaryApiSecret = true
                                secondaryApiSecret = ""
                            }
                        }
                    } else {
                        SecureField("Secondary API Secret", text: $secondaryApiSecret)
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(5)
                    }

                    Button("Save Secondary Nightscout") {
                        viewModel.saveSecondaryNightscout(
                            urlString: secondaryUrl,
                            apiSecret: secondaryApiSecret
                        )
                    }
                    .buttonStyle(ActionButtonStyle(.secondary))

                    HStack {
                        Text("Status")
                        Spacer()
                        Text(viewModel.secondaryStatusString)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            Button(action: {
                viewModel.didLogout?()
            } ) {
                Text("Logout").padding(.top, 20)
            }
        }
        .padding([.leading, .trailing])
        .onAppear {
            if secondaryUrl.isEmpty {
                secondaryUrl = viewModel.secondaryUrlString == "Not Configured" ? "" : viewModel.secondaryUrlString
            }
        }
        .navigationBarTitle("")
        .navigationBarItems(trailing: dismissButton)
    }
    
    private var dismissButton: some View {
        Button(action: dismiss) {
            Text("Done").bold()
        }
    }
}
