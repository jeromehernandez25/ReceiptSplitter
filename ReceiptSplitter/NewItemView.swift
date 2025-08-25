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
    @State private var priceText: String = ""   // CHANGED: store price as String
    @State private var person: String = ""

    var onSave: (ReceiptItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item Name", text: $name)

                TextField("Price", text: $priceText)   // CHANGED: bind to String
                    .keyboardType(.decimalPad)

                TextField("Person Responsible", text: $person)
            }
            .navigationTitle("New Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // CHANGED: Convert string to Double safely
                        let price = Double(priceText) ?? 0.0
                        let newItem = ReceiptItem(
                            name: name,
                            price: price,
                            person: person
                        )
                        onSave(newItem)
                        dismiss()
                    }
                    // Optional: Disable Save until all fields are filled
                    .disabled(name.isEmpty || person.isEmpty || priceText.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
