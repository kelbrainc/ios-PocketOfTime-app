//
//  Activity.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import Foundation

// A struct to represent a single activity idea.
// 'Codable' allows us to easily convert this to/from JSON (if needed).
struct Activity: Codable {
    let title: String
    let category: String
    let ageGroups: [String]
}

// 'CaseIterable' lets us easily turn all cases into an array.
enum AgeGroup: String, CaseIterable {
    case all = "All"
    case toddler = "Toddler"     // 1-3
    case preschool = "Preschool" // 3-6
    case kids = "Kids"         // 7-9
    case teens = "Teens"       // 10-12+
}

// enum case for categories
enum Category: String, CaseIterable {
    case all = "All"
    case indoors = "Indoors"
    case outdoors = "Outdoors"
    case creative = "Creative"
    case active = "Active"
    case quiet = "Mindful/Quiet"
}

