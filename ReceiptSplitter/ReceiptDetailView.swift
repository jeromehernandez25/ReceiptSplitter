//
//  ReceiptDetailView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import SwiftUI

struct ReceiptDetailView: View {
    @Binding var receipt: Receipt
    @State private var showingNewItem = false
    @State private var editingItem: ReceiptItem?   // for tap-to-edit

    // MARK: - Totals
    private var itemsSubtotal: Double {
        receipt.items.reduce(0) { $0 + $1.price }
    }
    private var grandTotal: Double {
        itemsSubtotal + receipt.tax + receipt.tip
    }

    // Local type for UI
    private struct PersonRow: Identifiable {
        var id: String { name }
        let name: String
        let subtotal: Double
        let taxShare: Double
        let tipShare: Double
        var total: Double { subtotal + taxShare + tipShare }
    }

    // Compute per-person totals using the *current* split mode
    private var perPersonRows: [PersonRow] {
        // subtotal by person (group by item.person)
        let subtotalsByPerson: [String: Double] = Dictionary(
            grouping: receipt.items, by: { $0.person.trimmingCharacters(in: .whitespaces) }
        ).mapValues { items in
            items.reduce(0) { $0 + $1.price }
        }

        let allSubtotal = subtotalsByPerson.values.reduce(0, +)
        let peopleCount = max(subtotalsByPerson.keys.count, 0)

        return subtotalsByPerson.keys.sorted().map { name in
            let subtotal = subtotalsByPerson[name] ?? 0

            let taxShare: Double
            let tipShare: Double
            switch receipt.splitMode {
            case .proportional:
                let r = allSubtotal > 0 ? subtotal / allSubtotal : 0
                taxShare = receipt.tax * r
                tipShare = receipt.tip * r
            case .equal:
                taxShare = peopleCount > 0 ? receipt.tax / Double(peopleCount) : 0
                tipShare = peopleCount > 0 ? receipt.tip / Double(peopleCount) : 0
            }

            return PersonRow(name: name, subtotal: subtotal, taxShare: taxShare, tipShare: tipShare)
        }
    }

    var body: some View {
        List {

            // ITEMS
            Section("Items") {
                ForEach($receipt.items) { $item in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).font(.headline)
                            Text(item.person)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("$\(item.price, specifier: "%.2f")")
                        Toggle("Paid", isOn: $item.paid).labelsHidden()
                    }
                    .contentShape(Rectangle())        // makes entire row tappable
                    .onTapGesture { editingItem = item } // open edit sheet
                }
                .onDelete { offsets in
                    receipt.items.remove(atOffsets: offsets)
                }

                Button {
                    showingNewItem = true
                } label: {
                    Label("Add Item", systemImage: "plus.circle")
                }
            }

            // SUMMARY (editable tax/tip)
            Section("Summary") {
                HStack {
                    Text("Items Subtotal")
                    Spacer()
                    Text("$\(itemsSubtotal, specifier: "%.2f")")
                }

                HStack {
                    Text("Tax")
                    Spacer()
                    TextField("0.00", value: $receipt.tax, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 80)
                }

                HStack {
                    Text("Tip")
                    Spacer()
                    TextField("0.00", value: $receipt.tip, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 80)
                }

                HStack {
                    Text("Grand Total")
                    Spacer()
                    Text("$\(grandTotal, specifier: "%.2f")")
                        .bold()
                }
            }

            // PER-PERSON TOTALS
            Section("Per-Person Totals") {
                ForEach(perPersonRows) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.name).font(.headline)
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text("$\(row.subtotal, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Tax share")
                            Spacer()
                            Text("$\(row.taxShare, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Tip share")
                            Spacer()
                            Text("$\(row.tipShare, specifier: "%.2f")")
                        }
                        Divider()
                        HStack {
                            Text("Total Owed")
                            Spacer()
                            Text("$\(row.total, specifier: "%.2f")").bold()
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // SPLIT OPTIONS
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
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
        }
        // New item sheet
        .sheet(isPresented: $showingNewItem) {
            NewItemView { newItem in
                receipt.items.append(newItem)
            }
        }
        // Edit item sheet
        .sheet(item: $editingItem) { item in
            EditItemView(item: binding(for: item))
        }
    }

    // Bind the correct array element for editing
    private func binding(for item: ReceiptItem) -> Binding<ReceiptItem> {
        guard let idx = receipt.items.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Editing item not found")
        }
        return $receipt.items[idx]
    }
}
