//
//  Memory.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//

import Foundation

nonisolated struct Memory: Codable, Hashable, Sendable {
    let id: UUID
    let text: String
    let date: Date
    let imageData: Data?
    
    // NEW: A property to track if the memory is liked.
    // We use 'var' so it can be changed. It defaults to false.
    var isLiked: Bool = false
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Memory, rhs: Memory) -> Bool {
        lhs.id == rhs.id
    }
}
