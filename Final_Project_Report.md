# MediCare - Semester Project Report

## 1. Introduction
MediCare is a comprehensive Flutter application designed to assist users in managing their daily medicine routines. It acts as a reliable companion that schedules medicine reminders, tracks daily intake progress, and ensures users never miss a dose.

## 2. Technical Stack
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Local Database:** Hive (NoSQL)
- **Backend Services:** Firebase (Authentication), External REST API (DummyJSON for Health Quotes)
- **Local Notifications:** `flutter_local_notifications`

## 3. Implementation of Required Modules

### Module 1: Authentication Module
- Implemented Login, Registration, and session management.
- Form validation to ensure proper email format and strong passwords.
- Integrated `AuthProvider` to handle user state across the app.

### Module 2: UI Module
- **Responsive Layout:** Adjusts gracefully across different screen sizes.
- **Navigation:** Implemented using Flutter named routes.
- **Components:** Dialogs, Custom Snackbars, Loading indicators (CircularProgressIndicator).
- **Theme Manager:** Supports Light/Dark mode and customizable color palettes.

### Module 3: Data Management (CRUD)
- **Create:** Add new medicines with specific doses, times, and icons.
- **Read:** View today's schedule and history of taken medicines.
- **Update:** Edit existing medicine details (time, name, frequency).
- **Delete:** Swipe-to-delete functionality with a confirmation dialog.

### Module 4: API / Backend Integration
- **HTTP Requests & JSON Parsing:** Integrated a REST API (`https://dummyjson.com/quotes/random`) using the `http` package to fetch and display a daily inspirational quote on the Home Screen.
- **Error Handling:** Implemented `try-catch` blocks to provide fallback quotes if the network fails.
- **Firebase:** Integrated Firebase Core for scalable backend potential.

### Module 5: State Management
- Utilized the `Provider` package to separate business logic from UI.
- `MedicineProvider` manages the CRUD operations and notifies listeners to update the UI instantly.
- `AuthProvider` manages the user session.

### Module 6: Navigation Module
- Setup clean Named Routes in `main.dart` (e.g., `/login`, `/main`, `/add`).
- Navigation with Arguments: Implemented in the Edit Medicine feature, passing the medicine object and index via `ModalRoute.of(context)!.settings.arguments`.

## 4. Distinct UI Screens (5+ Screens)
1. **Splash Screen:** Initial loading and branding.
2. **Login & Register Screens:** Authentication flow.
3. **Home Screen (Main):** Dashboard showing progress, daily medicines, and quotes.
4. **Add/Edit Medicine Screen:** Form for creating and modifying reminders.
5. **History Screen:** Log of past medicine intake.
6. **Profile Screen:** Settings, Theme selection, and Logout.

## 5. Extra Features (Optional requirements met)
- Background Alarms and Full-Screen Intent notifications for Android.
- Persistent local storage via Hive.
- Dynamic color themes (Pastel, Dark, Nature, Ocean).

## 6. AI Code Policy Declaration
*Parts of this project utilized AI-assisted coding tools for debugging and boilerplate generation. All code was reviewed, structured, and customized to fit the project requirements by the student.*
