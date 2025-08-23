//
//  EditItemView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/23/25.
//

import SwiftUI

struct EditItemView: View {
    @Binding var item: ReceiptItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                TextField("Item name", text: $item.name)
                TextField("Price", value: $item.price, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Person", text: $item.person)
                Toggle("Paid", isOn: $item.paid)
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}
