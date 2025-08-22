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
    @State private var tax = ""
    @State private var tip = ""

    var onSave: (Receipt) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Receipt Name", text: $title)
                TextField("Tax", text: $tax).keyboardType(.decimalPad)
                TextField("Tip", text: $tip).keyboardType(.decimalPad)
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
                            tax: Double(tax) ?? 0,
                            tip: Double(tip) ?? 0,
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
