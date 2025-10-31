//
//  Question.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//

import Foundation

//// conversation themes.
//// CaseIterable allows us to easily get a list of all themes.
//enum QuestionTheme: String, Codable, CaseIterable {
//    case sillyAndFun = "Silly & Fun"
//    case deepAndThoughtful = "Deep & Thoughtful"
//    case quickCheckIn = "Quick Check-in"
//    case whatIf = "What If..."
//}

// Question struct
nonisolated struct Question: Codable, Hashable {
    let id = UUID()
    let text: String
    //let theme: QuestionTheme
    
    enum CodingKeys: String, CodingKey {
        case text
    }
    
    // Conformance for Hashable, required for the data source.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
        
    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
    
}
