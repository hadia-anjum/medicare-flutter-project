# 📱 MediCare - Smart Medicine Reminder Application

MediCare is a human-centric cross-platform mobile application built using **Flutter** and **Dart**. Developed as a final semester project for the Mobile Application Development course, this application leverages mobile engineering principles to solve a widespread healthcare challenge: helping individuals systematically adhere to critical medication schedules.

---

## 📸 Application UI Showcase
All application walkthrough screenshots and UI designs are available in the main repository files above.

---

## 🧠 Technical Architecture & Core Modules

### 🔐 1. Authentication & Session Security (Module 1)
* **User Lifecycle Management:** Implemented secure user registration and login workflows with persistent session management.
* **Input Validation:** Robust client-side regex checks for secure emails and complex password architectures.

### 🎨 2. Immersive UI & Experience Optimization (Module 2)
* **Multi-Screen Workflow:** Configured a seamless interface spanning 5+ dedicated routes: Splash, Auth, Dashboard, Task Logs, and User Profiles.
* **Context Shifting Theme Engine:** Built a dynamic, status-based interface backing 4 custom themes: **Pastel, Ocean, Nature, and Dark** modes to improve user accessibility under varying lighting conditions.

### 💾 3. Data Persistence & Local CRUD (Module 3)
* **High-Speed Local Storage:** Integrated **Hive Database** to handle local configurations with low memory footprints.
* **Full CRUD Workflows:** Users can dynamically instantiate schedules, view active lists, update dose counts, and invoke context-aware swipe-to-delete flows with asynchronous verification dialogs.

### 🌐 4. Asynchronous Networking & State Management (Modules 4 & 5)
* **REST API Handlers:** Leveraged the `http` package to securely capture, parse, and map external JSON-based inspirational data models asynchronously.
* **Fault-Tolerant Logic:** Safe error boundaries utilizing try-catch blocks to feed elegant offline placeholders when device access is restricted.
* **Reactive Architecture:** Clean separation of concerns using the **Provider** pattern for decoupled state changes (`MedicineProvider`, `AuthProvider`).

### 🔔 5. Background Routines & Hardware Triggers (Module 6)
* **Local Notification Handlers:** Integrated `flutter_local_notifications` to safely register native system notifications and persistent alarm routines that successfully ring even when the application lifecycle is backgrounded.

---

## ⚙️ Tech Stack & Dependencies
* **Framework:** Flutter SDK
* **Core Engine:** Dart
* **Local Storage Engine:** Hive Database
* **State Containers:** Provider Pattern
* **Asynchronous Alert Triggers:** flutter_local_notifications

---

## 🚀 Setting Up the Project Locally

To run this repository locally on your development system, perform the following commands:

```bash
# 1. Clone the repository
git clone [https://github.com/hadia-anjum/medicare-flutter-project.git](https://github.com/hadia-anjum/medicare-flutter-project.git)

# 2. Access the root folder
cd medicare-flutter-project

# 3. Retrieve system dependencies
flutter pub get

# 4. Initialize on a running device or emulator
flutter run
