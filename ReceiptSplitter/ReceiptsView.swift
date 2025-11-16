//
//  ReceiptsView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//  Holds lists of receipts

import SwiftUI

struct ReceiptsView: View {
    @State private var receipts: [Receipt] = []
    @State private var path = NavigationPath()   // for navigation

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(receipts) { receipt in
                    NavigationLink(value: receipt) {
                        Text(receipt.title.isEmpty ? "Untitled Receipt" : receipt.title)
                    }
                }
                .onDelete(perform: deleteReceipt)
            }
            .navigationTitle("Receipts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {    // when tapped, creates and appends new receipt item
                    Button {
                        // Create a blank receipt
                        let newReceipt = Receipt(
                            title: "",
                            tax: 0,
                            tip: 0,
                            people: [],
                            items: []
                        )
                        receipts.append(newReceipt)

                        // Navigate directly to its detail view
                        path.append(newReceipt)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Receipt.self) { receipt in
                ReceiptDetailView(
                    receipt: binding(for: receipt)
                )
            }
        }
    }

    // Helper to get a binding for editing a receipt
    private func binding(for receipt: Receipt) -> Binding<Receipt> {
        guard let index = receipts.firstIndex(where: { $0.id == receipt.id }) else {
            fatalError("Receipt not found")
        }
        return $receipts[index]
    }

    private func deleteReceipt(at offsets: IndexSet) {
        receipts.remove(atOffsets: offsets)
    }
}
