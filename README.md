# MediCare - Smart Medicine Reminder 💊

MediCare is a Flutter application built as a final semester project for the Mobile Application Development course. It helps users manage their daily medicine intake with reliable background notifications, progress tracking, and a beautiful customizable UI.

## Features & Modules Implemented

1. **Authentication (Module 1):**
   - User Login and Registration with Session Management.
   - Form Validation for emails and strong passwords.

2. **User Interface (Module 2):**
   - **5+ Distinct Screens:** Splash, Login/Register, Dashboard, Add/Edit Medicine, History, and Profile.
   - Beautiful Animations, Dialogs, Snackbars, and Dynamic Themes (Pastel, Dark, Nature, Ocean).

3. **Data Management & CRUD (Module 3):**
   - **Create:** Add medicines with custom times, doses, and icons.
   - **Read:** Display today's schedule and past history.
   - **Update:** Edit existing medicines.
   - **Delete:** Swipe-to-delete with confirmation dialogs.

4. **API Integration (Module 4):**
   - Integrated REST API using the `http` package.
   - Fetches a random daily inspirational quote using JSON parsing.
   - Includes Error Handling (try-catch) to show fallback text when offline.

5. **State Management (Module 5):**
   - Clean architecture using the `Provider` package (`MedicineProvider`, `AuthProvider`).

6. **Navigation (Module 6):**
   - Named routes and Stack management.
   - Passing Arguments safely between screens (e.g., passing Medicine objects to the Edit Screen).

## Tech Stack
- **Framework:** Flutter SDK
- **Database:** Hive (Local Storage)
- **Backend Setup:** Firebase (Core initialized for future scalability)
- **Networking:** HTTP package
- **Notifications:** `flutter_local_notifications`

## How to Run
1. Clone the repository: `git clone <your-repo-link>`
2. Navigate to the project folder: `cd medicine_reminder`
3. Fetch dependencies: `flutter pub get`
4. Run the app on an Android Emulator or physical device: `flutter run`

## Building the APK for Submission
To generate a working APK for your final submission, run the following command in the terminal:
```bash
flutter build apk --release
```
The APK file will be saved in: `build\app\outputs\flutter-apk\app-release.apk`. You can rename this file to `MediCare_Final.apk` and submit it.

---
*Developed as a semester project. AI tools were partially used for boilerplate generation and bug fixing, adhering to course policies.*
