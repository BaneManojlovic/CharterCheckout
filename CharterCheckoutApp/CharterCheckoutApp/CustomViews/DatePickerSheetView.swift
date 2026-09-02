//
//  DatePickerSheetView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

struct DatePickerSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @State private var tempDate: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Select date").font(.title3.bold())
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 32)

            DatePicker("", selection: $tempDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)

            PrimaryButton(title: "Confirm") {
                selectedDate = tempDate
                dismiss()
            }
            .padding(.horizontal)
        }
    }
}
