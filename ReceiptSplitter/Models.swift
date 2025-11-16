//
//  Models.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import Foundation

// holds data for a person
// Identifiable lets struct be iterable in ForEach
// Codable lets struct be savable and loadable from storage
// Hashable lets struct values be used as sets or dictionary keys
struct Person: Identifiable, Codable, Hashable {
    var id = UUID()     // unique identifiers for each person (avoid same name issues)
    var name: String
    var paid: Bool = false
}

// holds data for a single item in a receipt
struct ReceiptItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var price: Double
    var people: [UUID] = []
}

// String gives each case a raw string value
// CaseIterable allows looping over the cases
enum SplitMode: String, CaseIterable, Codable, Identifiable {
    case proportional
    case equal

    var id: String { rawValue }
}

// holds all data for a single receipt
struct Receipt: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var tax: Double
    var tip: Double
    var people: [Person] = []
    var items: [ReceiptItem] = []
    var splitMode: SplitMode = .proportional
}

// Helper type for per-person summary
struct PersonTotal: Identifiable {
    var id: UUID { personId }
    var personId: UUID
    var name: String
    var subtotal: Double
    var taxShare: Double
    var tipShare: Double
    var total: Double
}

// keep Receipt struct simple by putting in-depth implementation here
extension Receipt {
    // Compute per-person totals by splitting item price evenly among assigned people
    var personTotals: [PersonTotal] {
        // create an array of tuples where each tuple's key is person's UUID and value is their Person struct
        // map person id to name to allow for instant lookups of person by UUID
        let personById: [UUID: Person] = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        
        // Initialize subtotals tuple that maps a person to their subtotal
        var subtotals: [UUID: Double] = [:]

        // Iterate through each item
        for item in items {
            guard !item.people.isEmpty else { continue }        // if item not assigned to anyone, skip it
            let share = item.price / Double(item.people.count)  // get how much person owes for this item
            for pid in item.people {                            // add share to their subtotal
                subtotals[pid, default: 0] += share
            }
        }
        
        let allSubtotals = subtotals.values.reduce(0, +)    // add up subtotals of each person
        let peopleCount = personById.count                  // get number of people on receipt

        // Build PersonTotal array for each person in the receipt.people order
        return people.map { person in
            let subtotal = subtotals[person.id] ?? 0.0  // if person had no items set subtotal to 0 instead of nil
            let taxShare: Double
            let tipShare: Double

            switch splitMode {
            case .proportional:
                // if group subtotal > 0, get proportional ratio for this person, else 0
                let ratio = allSubtotals > 0 ? subtotal / allSubtotals : 0
                taxShare = tax * ratio
                tipShare = tip * ratio
            case .equal:
                // if total people on bill > 0, split tax/tip equally for each person, else 0
                taxShare = peopleCount > 0 ? tax / Double(peopleCount) : 0
                tipShare = peopleCount > 0 ? tip / Double(peopleCount) : 0
            }

            return PersonTotal(
                personId: person.id,
                name: person.name,
                subtotal: subtotal,
                taxShare: taxShare,
                tipShare: tipShare,
                total: subtotal + taxShare + tipShare
            )
        }
        .sorted { $0.name < $1.name } // sort alphabetically
    }
}
