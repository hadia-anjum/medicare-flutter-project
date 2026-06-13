# 📱 MediCare - Smart Medicine Reminder Application

MediCare is a human-centric cross-platform mobile application built using **Flutter** and **Dart**. Developed as a final semester project for the Mobile Application Development course, this application leverages mobile engineering principles to solve a widespread healthcare challenge: helping individuals systematically adhere to critical medication schedules.

---

## 📸 Application UI Showcase
Here is a visual look into the clean, modern interface designed for optimized user accessibility:

<p align="left">
  <img src="https://github.com/hadia-anjum/medicare-flutter-project/blob/main/dashboard.jpg?raw=true" width="240" alt="Main Dashboard View" />
  <img src="https://github.com/hadia-anjum/medicare-flutter-project/blob/main/notification.jpg?raw=true" width="240" alt="Push Notification Trigger" />
  <img src="https://github.com/hadia-anjum/medicare-flutter-project/blob/main/themes.jpg?raw=true" width="240" alt="Multi-Theme Switching" />
</p>

*(Note: Make sure your uploaded image file names exactly match the paths inside the src attributes above, e.g., dashboard.jpg, notification.jpg).*

---

## 🧠 Technical Architecture & Core Modules

### 🔐 1. Authentication & Session Security (Module 1)
*   **User Lifecycle Management:** Implemented secure user registration and login workflows with persistent session management.
*   **Input Validation:** Robust client-side regex checks for secure emails and complex password architectures.

### 🎨 2. Immersive UI & Experience Optimization (Module 2)
*   **Multi-Screen Workflow:** Configured a seamless interface spanning 5+ dedicated routes: Splash, Auth, Dashboard, Task Logs, and User Profiles.
*   **Context Shifting Theme Engine:** Built a dynamic, status-based interface backing 4 custom themes: **Pastel, Ocean, Nature, and Dark** modes to improve user accessibility under varying lighting conditions.

### 💾 3. Data Persistence & Local CRUD (Module 3)
*   **High-Speed Local Storage:** Integrated **Hive Database** to handle local configurations with low memory footprints.
*   **Full CRUD Workflows:** Users can dynamically instantiate schedules, view active lists, update dose counts, and invoke context-aware swipe-to-delete flows with asynchronous verification dialogs.

### 🌐 4. Asynchronous Networking & State Management (Modules 4 & 5)
*   **REST API Handlers:** Leveraged the `http` package to securely capture, parse, and map external JSON-based inspirational data models asynchronously.
*   **Fault-Tolerant Logic:** Safe error boundaries utilizing try-catch blocks to feed elegant offline placeholders when device access is restricted.
*   **Reactive Architecture:** Clean separation of concerns using the **Provider** pattern for decoupled state changes (`MedicineProvider`, `AuthProvider`).

### 🔔 5. Background Routines & Hardware Triggers (Module 6)
*   **Local Notification Handlers:** Integrated `flutter_local_notifications` to safely register native system notifications and persistent alarm routines that successfully ring even when the application lifecycle is backgrounded.

---

## ⚙️ Tech Stack & Dependencies
*   **Framework:** Flutter SDK
*   **Core Engine:** Dart
*   **Local Storage Engine:** Hive Database
*   **State Containers:** Provider Pattern
*   **Asynchronous Alert Triggers:** flutter_local_notifications

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
flutter run<img width="1080" height="2123" alt="WhatsApp Image 2026-06-13 at 4 41 29 PM" src="https://github.com/user-attachments/assets/d791c3a3-5b8e-4b98-963c-c3cc49632a6a" />
<img width="1080" height="2134" alt="WhatsApp Image 2026-06-13 at 4 41 41 PM" src="https://github.com/user-attachments/assets/f8a12f12-72aa-4bb7-9166-1d4565357419" />
<img width="1080" height="2120" alt="WhatsApp Image 2026-06-13 at 4 41 55 PM" src="https://github.com/user-attachments/assets/4cd8bccc-9dea-422d-b961-d8d5eaf30dd4" />
<img width="1080" height="2123" alt="WhatsApp Image 2026-06-13 at 4 42 12 PM" src="https://github.com/user-attachments/assets/858e90b1-bf8d-44d9-9f44-0c5282f2da07" />
<img width="1080" height="2134" alt="WhatsApp Image 2026-06-13 at 4 42 29 PM" src="https://github.com/user-attachments/assets/de775cc2-039e-4537-a741-9a0927651766" />
<img width="1080" height="2129" alt="WhatsApp Image 2026-06-13 at 4 42 43 PM" src="https://github.com/user-attachments/assets/d29f4d79-4a8b-40ae-9e83-f4f8f21c146b" />
<img width="1080" height="2137" alt="WhatsApp Image 2026-06-13 at 4 42 57 PM" src="https://github.com/user-attachments/assets/25262f53-270c-4a01-80a6-7aedb8d778dc" />
<img width="1080" height="2126" alt="WhatsApp Image 2026-06-13 at 4 43 10 PM" src="https://github.com/user-attachments/assets/e84f1830-5d0b-4bc7-bb37-3a5f1bca6066" />
<img width="1080" height="2117" alt="WhatsApp Image 2026-06-13 at 4 49 37 PM" src="https://github.com/user-attachments/assets/ad5a82c8-a9fe-4a4c-84d9-b5d53df358ff" />
<img width="1080" height="526" alt="WhatsApp Image 2026-06-13 at 4 50 03 PM" src="https://github.com/user-attachments/assets/21b225f6-111b-49ba-9685-29310f10f011" />
