//
//  PersistenceManager.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import Foundation

// This class will handle saving and loading the user's memories.
class PersistenceManager {
    
    // 'static let' creates a "singleton" - a single, shared instance
    // that the whole app can use.
    static let shared = PersistenceManager()
    
    // We create a file URL to save our data to.
    // This goes in the app's "Documents" directory.
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("memories.json")
    }

    // Private init ensures no one else can create an instance.
    private init() {}

    // Loads all memories from the "memories.json" file
    func loadMemories() -> [Memory] {
        // 1. Check if the file even exists. If not, return an empty array.
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        
        // 2. If the file exists, try to decode it.
        do {
            let decoder = JSONDecoder()
            // We need to set a date decoding strategy
            decoder.dateDecodingStrategy = .iso8601
            let memories = try decoder.decode([Memory].self, from: data)
            return memories
        } catch {
            print("Error decoding memories: \(error)")
            return []
        }
    }
    
    // Saves an array of memories to the "memories.json" file
    func saveMemories(_ memories: [Memory]) {
        do {
            let encoder = JSONEncoder()
            // We set a date encoding strategy for compatibility
            encoder.dateEncodingStrategy = .iso8601
            // We use .prettyPrinted for debugging, you can remove this
            encoder.outputFormatting = .prettyPrinted 
            
            let data = try encoder.encode(memories)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Error encoding or saving memories: \(error)")
        }
    }
    
    // A simple helper to add one new memory
    func addMemory(_ memory: Memory) {
        // 1. Load the current list
        var memories = loadMemories()
        // 2. Add the new one
        memories.insert(memory, at: 0) // Insert at the front
        // 3. Save the new, larger list
        saveMemories(memories)
    }
    
    // A function to update a single memory in the saved array.
    // Finds a specific memory by its ID, updates it, and saves the entire list back to disk.
    func updateMemory(_ updatedMemory: Memory) {
        // 1. Load all the current memories.
        var memories = loadMemories()
            
        // 2. Find the index of the memory we need to update.
        if let index = memories.firstIndex(where: { $0.id == updatedMemory.id }) {
            // 3. Replace the old memory with the updated one.
            memories[index] = updatedMemory
                
            // 4. Save the entire modified array back to the file.
            saveMemories(memories)
        }
    }
}

