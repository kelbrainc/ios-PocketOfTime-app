# Pocket of Time  
**A Parenting App to Capture Little Moments That Matter**

Pocket of Time is a beautifully designed iOS app (UIKit, no Storyboard) that helps parents spend meaningful time with their children through fun short activities and conversation prompts, while capturing those cherished memories in one place.

---

## Features Overview

| Tab | Description |
|-----|--------------|
| **Activities** | Suggests simple, fun parent–child activities. Includes filters by age and category, a “Get a Fun Activity” button, and animated backgrounds. |
| **Conversations** | Provides creative daily questions to spark meaningful family discussions. Supports left/right swiping through history with animated animals and hearts. |
| **Moments** | Lets parents save captured memories with photos and text. Memories are displayed as beautiful cards with date filters, liking, and detailed viewing. |

---

## App Highlights

### Modern UIKit Architecture
- Fully **programmatic UI (no Storyboards)**.
- Uses **UICollectionViewCompositionalLayout** for flexible layouts.
- Implements **Diffable Data Source** for efficient updates.
- Reusable custom cells (`MemoryCell`, `TopMomentCell`, etc.).
- Delegation patterns for data flow between view controllers.

### Custom Visual Design
- Dynamic **glass-blur backgrounds** (`UIBlurEffect`) for depth.
- Consistent **system indigo theme**.
- Subtle **animations** (floating orbs, animal runs, heart ripples).
- Modern **material-like UI** that adapts to dark and light modes.

### Persistence
- Uses `PersistenceManager` (JSON-based storage) to persist:
  - Saved moments
  - Liked memories
  - Captured photos
- Data is reloaded and synced across tabs automatically.

### Memory Capture Flow
1. Tap **Camera** on the Activities page, or “+” in Moments tab.  
2. Opens the **Add Memory** view (UIKit form).  
3. User enters a description and optionally selects a photo.  
4. Memory saved locally and displayed instantly in the Moments dashboard.

### Conversations Flow
- On app open, user sees a **Question of the Day**.  
- Swipe **left** for a new question, **right** to revisit previous ones.  
- Cute animated hearts and running animals bring a playful, family-friendly tone.

---

## Project Architecture
PocketOfTime
|--App/
|--AppDelegate.swift
|--SceneDelegate.swift
|--Onboarding/
|--OnboardingContentViewController.swift
|--OnboardingSlide.swift
|--OnboardingViewController.swift
|--Activities/
|--ActivitiesViewController.swift
|--FilterCell.swift
|--FilterViewController.swift
|--Conversations/
|--ConversationViewController.swift
|--Moments/
|--AddMemoryViewController.swift
|--CalendarFilterViewController.swift
|--EmptyStateCell.swift
|--FilteredMomentViewController.swift
|--MemoryCell.swift
|--MemoryDetailViewController.swift
|--MyMomentsViewController.swift
|--TopMomentCell.swift
|--Models/
|--Activity.swift
|--Memory.swift
|--Question.swift
|--Shared/
|--Data/
|--ContentData.swift
|--Managers/
|--PersistenceManager.swift
|--View/
|--SpotlightCardView.swift

---

## Technical Details

| Category | Technology |
|-----------|-------------|
| Language | Swift 5 |
| Framework | UIKit (no Storyboard) |
| Minimum iOS | iOS 15 (tested on iOS 18) |
| Architecture | MVC + Delegation |
| Layouts | Auto Layout + Compositional Layout |
| Data | Codable + File Persistence |
| Animations | UIViewPropertyAnimator + UIKit Dynamics |
| Media | UIImagePickerController for photo capture |
| Storage | Local JSON file (PersistenceManager) |

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/PocketOfTime.git
   cd PocketOfTime

2. Open in Xcide:
   ``` bash
   open PocketOfTime.xcodeproj

3. Build and run:
   - Choose an iPhone simulator (or your device)
   - Press CmD + R to build and launch
  
---

## Developer Notes
- Compatible with real iPhone deployment (iOS 17–18).
- Originally used UIGlassEffect and .prominentGlass() (replaced with iOS-compatible UIBlurEffect and .borderedProminent()). Uncomment codes to use for iOS 26.
