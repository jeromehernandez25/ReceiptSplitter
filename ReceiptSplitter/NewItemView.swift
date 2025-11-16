//
//  NewItemView.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import SwiftUI

struct NewItemView: View {
    @Environment(\.dismiss) var dismiss     // NewItemView is presented modally and want it to be closable
    @State private var name: String = ""        // use states to store mutable local data
    @State private var priceText: String = ""
    @State private var selectedPeople: Set<UUID> = []

    // Provide the available people (snapshot) so user can select from them
    var people: [Person]
    
    var onSave: (ReceiptItem) -> Void

    var body: some View {
        NavigationStack { // use a navigation stack to title Add Item window and have toolbar buttons
            Form { // use form to have grouped rows, automatic ios spacing, scrolling behavior, section headers
                Section{
                    TextField("Item Name", text: $name)
                    TextField("Price", text: $priceText)
                        .keyboardType(.decimalPad)
                }
                Section("People Responsible") {
                    if people.isEmpty { // display message if no assigned people??
                        Text("No people added to this receipt yet.")
                            .foregroundColor(.secondary)
                    } else {    // display each person and have tappable selection for item responsibility
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
            .navigationTitle("New Item")
            .toolbar { // toolbar adds buttons to the navigation bar
                ToolbarItem(placement: .confirmationAction) { // placement: .confirmationAction places button on right side
                    Button("Save") {
                        let price = Double(priceText) ?? 0.0 // if priceText has value, set to price to priceText, else set price to null
                        let newItem = ReceiptItem(
                            name: name,
                            price: price,
                            people: Array(selectedPeople)
                        )
                        onSave(newItem)
                        dismiss()
                    }
                    // disable Save until all fields are filled
                    .disabled(name.isEmpty || priceText.isEmpty || priceText.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) { // place button on left side
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    private func toggleSelection(for id: UUID) { // helper function to flip state of person when tapped
        if selectedPeople.contains(id) {
            selectedPeople.remove(id)
        } else {
            selectedPeople.insert(id)
        }
    }
}
