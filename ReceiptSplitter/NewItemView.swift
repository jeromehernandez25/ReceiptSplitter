//
//  NewItemView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import SwiftUI

struct NewItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var price: Double = 0.0
    @State private var person: String = ""

    var onSave: (ReceiptItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item Name", text: $name)
                TextField("Price", value: $price, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Person Responsible", text: $person)
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newItem = ReceiptItem(name: name, price: price, person: person)
                        onSave(newItem)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
