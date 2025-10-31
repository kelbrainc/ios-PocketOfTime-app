//
//  ContentData.swift
//  PocketOfTimev3
//
//  Created by Kelly Chui on 24/10/25.
//


import Foundation

// This struct acts as a static database?
struct ContentData {
    
    // We can access this list from anywhere in the app
    // using 'ContentData.activities'
    static let activities: [Activity] = [
        // Original 5 activities
        Activity(title: "Build a pillow fort in the living room.", category: "Indoors", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Find 5 red things in the house.", category: "Indoors", ageGroups: ["Toddler", "Preschool"]),
        Activity(title: "Have an indoor picnic (on the floor!).", category: "Indoors", ageGroups: ["Toddler", "Preschool", "Kids"]),
        Activity(title: "Draw a map of your neighborhood.", category: "Indoors", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Play 'I Spy' for 10 minutes.", category: "Indoors", ageGroups: ["Toddler", "Preschool"]),
        
        // The 50 "remote" activities, now bundled safely
        Activity(title: "Make shadow puppets on the wall.", category: "Indoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Play 'I Spy' with things in the room.", category: "Indoors", ageGroups: ["Toddler", "Preschool"]),
        Activity(title: "Have a 'Floor is Lava' game across the living room.", category: "Active", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Make paper airplanes and have a flight contest.", category: "Creative", ageGroups: ["Kids", "Tweens"]),
        Activity(title: "Tell a story one sentence at a time, taking turns.", category: "Creative", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "See who can balance on one foot the longest.", category: "Active", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Draw a portrait of each other without looking down.", category: "Creative", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Invent a secret handshake.", category: "Indoors", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Have a dance party to one favorite song.", category: "Active", ageGroups: ["Toddler", "Preschool", "Kids", "Teens"]),
        Activity(title: "Play 'Rock, Paper, Scissors' (best of 5).", category: "Indoors", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Find 5 different types of leaves outside.", category: "Outdoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Lie on the grass and watch the clouds float by.", category: "Outdoors", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Go on a 'listening walk' and name every sound you hear.", category: "Outdoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Stack pillows as high as they can go without falling.", category: "Indoors", ageGroups: ["Toddler", "Preschool"]),
        Activity(title: "Try to write your name with your non-dominant hand.", category: "Creative", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Build a house of cards.", category: "Mindful/Quiet", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Pretend to be different animals and guess which one.", category: "Active", ageGroups: ["Toddler", "Preschool"]),
        Activity(title: "Draw a map of your bedroom from memory.", category: "Creative", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Play the 'Quiet Game' for one minute.", category: "Mindful/Quiet", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Find 5 things in the house smaller than your thumb.", category: "Indoors", ageGroups: ["Toddler", "Preschool", "Kids"]),
        Activity(title: "Play 'Simon Says'.", category: "Active", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Make up a silly poem together.", category: "Creative", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Practice making funny faces in a mirror.", category: "Indoors", ageGroups: ["Toddler", "Preschool", "Kids"]),
        Activity(title: "Create a 'band' using pots, pans, and spoons.", category: "Active", ageGroups: ["Toddler", "Preschool", "Kids"]),
        Activity(title: "Try to pat your head and rub your tummy at the same time.", category: "Indoors", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Have a staring contest.", category:"Mindful/Quiet", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Draw a monster, taking turns adding one body part.", category: "Creative", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "See who can make the best bird call.", category: "Indoors", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Sing 'Head, Shoulders, Knees, and Toes' as fast as you can.", category: "Active", ageGroups: ["Toddler", "Preschool"]),
        Activity(title: "Count all the windows in your home.", category: "Indoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Find a bug outside and give it a name.", category: "Outdoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Create a museum of 5 interesting household objects.", category: "Creative", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Read one short book out loud with funny voices.", category: "Mindful/Quiet", ageGroups: ["Toddler", "Preschool", "Kids"]),
        Activity(title: "Learn to fold a simple origami animal.", category: "Creative", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Give a 2-minute 'tour' of the house.", category: "Indoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Make up a new, silly word and define it.", category: "Creative", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Do 10 jumping jacks together.", category: "Active", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Trace your hands on a piece of paper.", category: "Creative", ageGroups: ["Toddler", "Preschool"]),
        Activity(title: "Whisper a secret and pass it on.", category: "Mindful/Quiet", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Make a list of 10 things you're grateful for.", category: "Mindful/Quiet", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Race two leaves down a stream or puddle.", category: "Outdoors", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Draw your favorite animal with chalk on the sidewalk.", category: "Outdoors", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Try to guess a song by just humming the tune.", category: "Indoors", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Have a thumb war tournament.", category: "Active", ageGroups: ["Kids", "Teens"]),
        Activity(title: "See how many rhymes you can make for the word 'cat'.", category: "Creative", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Build a 'nest' out of couch cushions.", category: "Creative", ageGroups: ["Toddler", "Preschool", "Kids"]),
        Activity(title: "Try to touch your toes (or knees, or shins!).", category: "Active", ageGroups: ["Preschool", "Kids"]),
        Activity(title: "Listen to a song and draw whatever it makes you think of.", category: "Creative", ageGroups: ["Preschool", "Kids", "Teens"]),
        Activity(title: "Write a secret code message for someone to find.", category: "Creative", ageGroups: ["Kids", "Teens"]),
        Activity(title: "Find a cool rock, bring it inside, and name it.", category: "Outdoors", ageGroups: ["Toddler", "Preschool", "Kids"])
    ]
    
    // We can access this list from anywhere in the app
    // using 'ContentData.questions'
    static let questions: [Question] = [
            // Original 5 questions
            Question(text: "If you could have any superpower, what would it be and why?"),
            Question(text: "What was the funniest thing that happened today?"),
            Question(text: "If our pet could talk, what would it say?"),
            Question(text: "What's one thing you want to do this weekend?"),
            Question(text: "What new thing did you learn today?"),
            
            // New 30 questions
            Question(text: "If you could invent a new holiday, what would it celebrate?"),
            Question(text: "What's the best smell in the world?"),
            Question(text: "If you could be any animal for a day, which one would you choose?"),
            Question(text: "What makes you feel really happy?"),
            Question(text: "If you could travel anywhere in the world right now, where would you go?"),
            Question(text: "What's your favorite sound?"),
            Question(text: "If you could have dinner with any cartoon character, who would it be?"),
            Question(text: "What's something you're really good at?"),
            Question(text: "If you could make one rule that everyone in the world had to follow, what would it be?"),
            Question(text: "What's the silliest dream you've ever had?"),
            Question(text: "If you could change your name, what would you change it to?"),
            Question(text: "What's your favorite thing about winter?"),
            Question(text: "If you found a treasure chest, what would you hope is inside?"),
            Question(text: "What's something that always makes you laugh?"),
            Question(text: "If you could design a new playground, what would it have?"),
            Question(text: "What's the kindest thing someone did for you today (or this week)?"),
            Question(text: "If you could talk to trees, what would you ask them?"),
            Question(text: "What's your favorite game to play?"),
            Question(text: "If you could shrink down to the size of an ant, what would you do?"),
            Question(text: "What's something you wish you could do better?"),
            Question(text: "If you could build a robot, what would you want it to do?"),
            Question(text: "What's your favorite memory from when you were little?"),
            Question(text: "If you could give everyone in the world one gift, what would it be?"),
            Question(text: "What's the most interesting thing you saw today?"),
            Question(text: "If you could live in a book or movie, which one would it be?"),
            Question(text: "What are you most looking forward to tomorrow?"),
            Question(text: "If you could fly, where would you go first?"),
            Question(text: "What's something brave you did recently?"),
            Question(text: "If you could have any magical creature as a pet, what would you choose?"),
            Question(text: "What song always makes you want to dance?")
        ]
    
    // selects a question based on the current day of the year.
    // ensures every user sees the same question on the same day.
    static func getQuestionOfTheDay() -> Question? {
        // Get the current calendar and day of the year (e.g., October 29 is day 302).
        let calendar = Calendar.current
        guard let dayOfTheYear = calendar.ordinality(of: .day, in: .year, for: Date()) else {
            // As a fallback, return a random question if the date fails.
            return questions.randomElement()
        }
        
        guard !questions.isEmpty else { return nil }
        
        // Use the modulo operator to get an index that is always within the bounds of our questions array.
        let index = dayOfTheYear % questions.count
        return questions[index]
    }
}
