//
//  NewReceiptView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import SwiftUI

struct NewReceiptView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var tax: Double? = nil
    @State private var tip: Double? = nil

    var onSave: (Receipt) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Receipt Name", text: $title)

                // Tax field
                HStack {
                    Text("Tax")
                    Spacer()
                    HStack(spacing: 2) {   // tighter spacing
                        Text("$")
                        TextField("0.00", value: $tax, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 60)
                    }
                }

                // Tip field
                HStack {
                    Text("Tip")
                    Spacer()
                    HStack(spacing: 2) {
                        Text("$")
                        TextField("0.00", value: $tip, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 60)
                    }
                }
            }
            .navigationTitle("New Receipt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newReceipt = Receipt(
                            title: title,
                            tax: tax ?? 0,
                            tip: tip ?? 0,
                            items: []
                        )
                        onSave(newReceipt)
                        dismiss()
                    }
                }
            }
        }
    }
}
