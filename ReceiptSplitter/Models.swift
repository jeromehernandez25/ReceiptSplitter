//
//  Models.swift
//  ReceiptSplitter
//
//  Created by Jerome Hernandez on 8/21/25.
//

import Foundation

struct ReceiptItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var price: Double
    var person: String      // one person per item (simple to start)
    var paid: Bool = false  // checkbox in the UI
}

enum SplitMode: String, CaseIterable, Codable, Identifiable {
    case proportional
    case equal

    var id: String { rawValue }
}

struct Receipt: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var tax: Double
    var tip: Double
    var items: [ReceiptItem] = []
    var splitMode: SplitMode = .proportional
}

// Helper type for per-person summary
struct PersonTotal: Identifiable {
    var id: String { name }
    var name: String
    var subtotal: Double
    var taxShare: Double
    var tipShare: Double
    var total: Double
}

extension Receipt {
    var personTotals: [PersonTotal] {
        let grouped = Dictionary(grouping: items, by: { $0.person })

        let subtotalPerPerson = grouped.mapValues { $0.reduce(0) { $0 + $1.price } }
        let allSubtotals = subtotalPerPerson.values.reduce(0, +)
        let peopleCount = subtotalPerPerson.keys.count

        return subtotalPerPerson.map { (person, subtotal) in
            let taxShare: Double
            let tipShare: Double

            switch splitMode {
            case .proportional:
                let ratio = allSubtotals > 0 ? subtotal / allSubtotals : 0
                taxShare = tax * ratio
                tipShare = tip * ratio
            case .equal:
                taxShare = peopleCount > 0 ? tax / Double(peopleCount) : 0
                tipShare = peopleCount > 0 ? tip / Double(peopleCount) : 0
            }

            return PersonTotal(
                name: person,
                subtotal: subtotal,
                taxShare: taxShare,
                tipShare: tipShare,
                total: subtotal + taxShare + tipShare
            )
        }
        .sorted { $0.name < $1.name }
    }
}
