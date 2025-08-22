//
//  ReceiptDetailView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import SwiftUI

struct ReceiptDetailView: View {
    @Binding var receipt: Receipt
    @State private var showingNewItem = false   // for sheet

    var body: some View {
        List {
            // Items section
            Section("Items") {
                ForEach(receipt.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        HStack {
                            Text("Price: $\(item.price, specifier: "%.2f")")
                            Spacer()
                            Text("Person: \(item.person)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
            }

            // Summary section
            Section("Summary") {
                HStack {
                    Text("Tax")
                    Spacer()
                    Text("$\(receipt.tax, specifier: "%.2f")")
                }
                HStack {
                    Text("Tip")
                    Spacer()
                    Text("$\(receipt.tip, specifier: "%.2f")")
                }
                HStack {
                    Text("Total")
                    Spacer()
                    let total = receipt.items.reduce(0) { $0 + $1.price } + receipt.tax + receipt.tip
                    Text("$\(total, specifier: "%.2f")")
                        .bold()
                }
            }

            // Per-person totals
            Section("Per-Person Totals") {
                ForEach(receipt.personTotals) { personTotal in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(personTotal.name)
                            .font(.headline)
                        HStack {
                            Text("Subtotal:")
                            Spacer()
                            Text("$\(personTotal.subtotal, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Tax share:")
                            Spacer()
                            Text("$\(personTotal.taxShare, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Tip share:")
                            Spacer()
                            Text("$\(personTotal.tipShare, specifier: "%.2f")")
                        }
                        Divider()
                        HStack {
                            Text("Total Owed:")
                            Spacer()
                            Text("$\(personTotal.total, specifier: "%.2f")")
                                .bold()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Split mode picker
            Section("Split Options") {
                Picker("Tax & Tip Split", selection: $receipt.splitMode) {
                    ForEach(SplitMode.allCases) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle(receipt.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewItem) {
            NewItemView { newItem in
                receipt.items.append(newItem)
            }
        }
    }
}
