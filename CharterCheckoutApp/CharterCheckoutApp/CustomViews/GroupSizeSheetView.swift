//
//  GroupSizeSheetView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

struct GroupSizeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var adults: Int
    @Binding var children: Int

    @State private var tempAdults: Int
    @State private var tempChildren: Int

    init(adults: Binding<Int>, children: Binding<Int>) {
        self._adults = adults
        self._children = children
        self._tempAdults = State(initialValue: adults.wrappedValue)
        self._tempChildren = State(initialValue: children.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)
            HStack {
                Text("How many people?").font(.title3.bold())
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                countRow(title: "Adults", subtitle: "Ages 13 or above", count: $tempAdults, minimum: 1)
                Divider()
                countRow(title: "Children", subtitle: "Ages 2–12", count: $tempChildren, minimum: 0)
            }
            .padding(.horizontal)

            Spacer()

            Button {
                adults = tempAdults
                children = tempChildren
                dismiss()
            } label: {
                Text("Confirm").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .padding(.bottom, 4)
    }

    private func countRow(title: String, subtitle: String, count: Binding<Int>, minimum: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                count.wrappedValue = max(minimum, count.wrappedValue - 1)
            } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .disabled(count.wrappedValue <= minimum)

            Text("\(count.wrappedValue)").frame(minWidth: 24)

            Button {
                count.wrappedValue += 1
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
        }
        .padding(.vertical, 12)
    }
}
