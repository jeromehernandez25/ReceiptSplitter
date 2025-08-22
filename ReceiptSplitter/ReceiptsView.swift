//
//  ReceiptsView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import SwiftUI

struct ReceiptsView: View {
    @State private var receipts: [Receipt] = []
    @State private var showingNewReceipt = false

    var body: some View {
        NavigationView {
            List {
                ForEach(receipts) { receipt in
                    NavigationLink(destination: ReceiptDetailView(receipt: binding(for: receipt))) {
                        Text(receipt.title)
                    }
                }
            }
            .navigationTitle("Receipts")
            .toolbar {
                Button(action: { showingNewReceipt = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingNewReceipt) {
                NewReceiptView(onSave: { newReceipt in
                    receipts.append(newReceipt)
                })
            }
        }
    }

    private func binding(for receipt: Receipt) -> Binding<Receipt> {
        guard let index = receipts.firstIndex(where: { $0.id == receipt.id }) else {
            fatalError("Receipt not found")
        }
        return $receipts[index]
    }
}
