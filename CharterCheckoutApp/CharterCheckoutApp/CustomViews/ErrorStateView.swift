//
//  ErrorStateView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 3. 9. 2026..
//

import Foundation
import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: Strings.Errors.retry, action: onRetry)
                .frame(maxWidth: 200)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}
