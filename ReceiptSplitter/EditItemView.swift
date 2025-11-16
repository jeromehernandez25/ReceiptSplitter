//
//  EditItemView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/23/25.
//

import SwiftUI

struct EditItemView: View {
    @Binding var item: ReceiptItem
    var people: [Person]
    @Environment(\.dismiss) private var dismiss

    @State private var nameCopy: String = ""
    @State private var priceText: String = ""
    @State private var selectedPeople: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item name", text: $item.name)
                TextField("Price", value: $item.price, format: .number)
                    .keyboardType(.decimalPad)
                Section("People Responsible") {
                    if people.isEmpty {
                        Text("No people in receipt")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(people) { person in
                            Button {
                                toggleSelection(for: person.id)
                            } label: {
                                HStack {
                                    Text(person.name)
                                    Spacer()
                                    if selectedPeople.contains(person.id) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        item.name = nameCopy
                        item.price = Double(priceText) ?? 0.0
                        item.people = Array(selectedPeople)
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadFromBinding)
        }
    }
    private func loadFromBinding() {
        nameCopy = item.name
        priceText = String(format: "%.2f", item.price)
        selectedPeople = Set(item.people)
    }

    private func toggleSelection(for id: UUID) {
        if selectedPeople.contains(id) {
            selectedPeople.remove(id)
        } else {
            selectedPeople.insert(id)
        }
    }
}
