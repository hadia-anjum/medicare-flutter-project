# MediCare - Presentation Outline (10 Slides)

## Slide 1: Title Slide
- **Project Title:** MediCare - Your Personal Medicine Reminder
- **Course Name:** Flutter Mobile Application Development
- **Group Members:** [Your Name/ID] & [Partner Name/ID]
- **Instructor:** [Instructor's Name]

## Slide 2: Introduction & Problem Statement
- **Problem:** People often forget to take their daily medications on time, leading to health complications.
- **Solution:** MediCare provides an intuitive, reliable alarm system and progress tracker to ensure users never miss a dose.

## Slide 3: Application Features
- Secure Login and Registration.
- Add, Edit, and Delete Medicine Reminders.
- Local Notifications & Background Alarms.
- Daily Progress Tracker and History Log.
- REST API Integration for Daily Health Inspiration Quotes.

## Slide 4: Technical Architecture
- **Framework:** Flutter
- **State Management:** Provider
- **Local Database:** Hive (Fast NoSQL storage)
- **Backend:** Firebase (Authentication setup)
- **API:** REST API using the `http` package and JSON parsing.

## Slide 5: Module 1 & 2 - Auth & UI
- **Authentication:** Custom forms with Regex validation, session retention.
- **UI Design:** Implemented dynamic Themes (Pastel, Dark, Nature, Ocean). Responsive layout with intuitive navigation and loading indicators.

## Slide 6: Module 3 - CRUD Operations (Data Management)
- **Create:** Form to schedule medicine with time, frequency, and icon.
- **Read:** Dashboard fetching today's active medicines.
- **Update:** Pre-filled Edit Screen passing arguments via Named Routes.
- **Delete:** Swipe-to-delete with Alert Dialog confirmation.

## Slide 7: Module 4 - API / Backend Integration
- Integrated `http` package to call a public JSON API.
- Parsed JSON response to display a "Daily Inspiration Quote" on the home dashboard.
- Implemented robust error handling (`try-catch`) if offline.

## Slide 8: Module 5 & 6 - State Management & Navigation
- **Provider:** `MedicineProvider` manages the app's core state without cluttering UI components.
- **Navigation:** Defined Named Routes (`/login`, `/main`, `/edit`) in `main.dart` for clean and scalable stack management.

## Slide 9: Challenges & Learnings
- **Challenges:** Handling Background Notifications on Android 12+, Managing State across multiple nested widgets.
- **Learnings:** Deep understanding of Provider, asynchronous programming in Dart, and handling platform-specific permissions.

## Slide 10: Live Demo & Q/A
- **Demo Time!** (Switch to screen mirroring to show the working app).
- Show Login -> Add Medicine -> Mark as Taken -> Swipe to Delete -> Change Theme.
- Thank You! Any Questions?
