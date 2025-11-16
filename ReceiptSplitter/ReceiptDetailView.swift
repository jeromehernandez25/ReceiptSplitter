//
//  ReceiptDetailView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//  Show details for a single receipt including people responsible, items,
//  tax/tip, splitt settings, and calculated totals for each person

import SwiftUI

struct ReceiptDetailView: View {
    @Binding var receipt: Receipt
    @State private var showingNewItem = false
    @State private var editingItem: ReceiptItem?   // for tap-to-edit
    @FocusState private var titleFocused: Bool     // for focusing title field

    // MARK: - Totals
    private var itemsSubtotal: Double {
        // Sum of all item prices (note: items may be split across people)
        receipt.items.reduce(0) { $0 + $1.price }
    }
    private var grandTotal: Double {
        itemsSubtotal + receipt.tax + receipt.tip
    }

    // Local type for UI
    private struct PersonRow: Identifiable {
        var id: UUID { personId }
        let personId: UUID
        let name: String
        let subtotal: Double
        let taxShare: Double
        let tipShare: Double
        var total: Double { subtotal + taxShare + tipShare }
        var paid: Bool
    }

    // Compute per-person rows using receipt.personTotals and reflect paid state
    private var perPersonRows: [PersonRow] {
        let totals = receipt.personTotals
        // Build mapping id -> paid status & name (from receipt.people)
        let paidById: [UUID: Bool] = Dictionary(uniqueKeysWithValues: receipt.people.map { ($0.id, $0.paid) })
        let namesById: [UUID: String] = Dictionary(uniqueKeysWithValues: receipt.people.map { ($0.id, $0.name) })

        return totals.map { t in
            PersonRow(
                personId: t.personId,
                name: namesById[t.personId] ?? t.name,
                subtotal: t.subtotal,
                taxShare: t.taxShare,
                tipShare: t.tipShare,
                paid: paidById[t.personId] ?? false
            )
        }
    }

    var body: some View {
        List {
            // RECEIPT TITLE (editable at top)
            Section {
                TextField("Receipt Title", text: $receipt.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .focused($titleFocused)
            }
            
            // PEOPLE RESPONSIBLE
            Section("People Responsible") {
                ForEach($receipt.people) { $person in
                    HStack {
                        TextField("Name", text: $person.name)
                        Spacer()
                        Toggle("Paid", isOn: $person.paid)
                            .labelsHidden()
                    }
                }
                .onDelete { offsets in
                    // Remove person and also remove references from items
                    let idsToRemove = offsets.map { receipt.people[$0].id }
                    receipt.people.remove(atOffsets: offsets)
                    for id in idsToRemove {
                        // Remove the person from any items that referenced them
                        for idx in receipt.items.indices {
                            receipt.items[idx].people.removeAll { $0 == id }
                        }
                    }
                }

                Button {
                    receipt.people.append(Person(name: ""))
                } label: {
                    Label("Add Person", systemImage: "plus")
                }
            }


            // ITEMS
            Section("Items") {
                ForEach($receipt.items) { $item in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).font(.headline)
                            // Show comma-separated list of assigned people
                            let assignedNames = item.people.compactMap { pid in
                                receipt.people.first(where: { $0.id == pid })?.name
                            }.joined(separator: ", ")
                            Text(assignedNames.isEmpty ? "Unassigned" : assignedNames)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("$\(item.price, specifier: "%.2f")")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingItem = item
                    }
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
                    TextField("0.00", value: $receipt.tax, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 100)
                }
                

                HStack {
                    Text("Tip")
                    Spacer()
                    TextField("0.00", value: $receipt.tip, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 100)
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
                        HStack {
                            Text(row.name).font(.headline)
                            Spacer()
                            if row.paid {
                                Label("Paid", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
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
            NewItemView(people: receipt.people) { newItem in
                receipt.items.append(newItem)
            }
        }
        // Edit item sheet
        .sheet(item: $editingItem) { item in
            EditItemView(item: binding(for: item), people: receipt.people)
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
