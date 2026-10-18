# Mr. Guide - Mobile Application (Flutter)

Explore Sri Lanka — Mobile frontend application connected to the live Node.js + PostgreSQL backend.

---

## 🚀 Quick Setup Guide for Team Members

Follow these steps to pull the latest changes, install dependencies, and run the app on your physical Android device using **Mobile Data**.

---

### 1. Prerequisites

Before starting, ensure you have the following installed on your computer:
* **Flutter SDK** (`^3.9.0` or higher) — [Install Flutter](https://docs.flutter.dev/get-started/install)
* **Android Studio** or **VS Code** with Flutter & Dart extensions
* An **Android Physical Device** with **Developer Options & USB Debugging** enabled

---

### 2. Pull the Latest Code

Open your terminal and pull the latest commits from the repository:

```bash
# If you are cloning for the first time:
git clone <repository_url>
cd Mr-Guide-Latest

# If you already have the repository:
git checkout <branch_name>
git pull origin <branch_name>
```

---

### 3. Install Dependencies

Fetch all required packages (such as `http`, `flutter_map`, `shared_preferences`, etc.):

```bash
flutter pub get
```

---

### 4. Backend Configuration (Ready to Use)

The app is **pre-configured** to connect directly to the live Production Backend hosted on Render:
* **Base URL:** `https://mrguide-backend.onrender.com/api`
* Location: `lib/config/api_config.dart`

> ℹ️ **No local Node.js or PostgreSQL backend setup is required!**  
> The app connects directly to the cloud server over the internet.

---

### 5. Running on a Physical Device

#### Method A: Direct Run via USB (Recommended for Development)

1. Connect your Android device to your computer via USB cable.
2. Enable **USB Debugging** on your device (*Settings > Developer Options > USB Debugging*).
3. Verify that your computer recognizes the device:
   ```bash
   flutter devices
   ```
4. Run the app on your device:
   ```bash
   flutter run
   ```
5. Once the app starts up on your device:
   * **Unplug the USB cable** (optional).
   * **Turn on Mobile Data** (Dialog, Mobitel, etc.).
   * The app will now communicate directly with the live Render cloud backend over Mobile Data!

---

#### Method B: Build & Install Release APK (No Computer Needed Afterwards)

If you want an APK file that can be installed on any phone:

1. Build the release APK:
   ```bash
   flutter build apk --release
   ```
2. The generated APK will be located at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```
3. Transfer this `.apk` file to your phone via USB, WhatsApp, or Google Drive and install it.
4. Open the app on your phone with **Mobile Data** enabled.

---

## ⚠️ Important Note: Render Cold Start

The backend is hosted on Render's free tier. If the backend hasn't been accessed recently, the server goes into sleep mode:

* **First Request Delay:** The first request (e.g., Login or Create Account) will take **30 to 50 seconds** while the server wakes up.
* **Loading State:** The app displays a loading spinner and a notice:  
  *`"Connecting to server... (First request may take 30-50s on Render)"`*
* **Subsequent Requests:** Once the server is awake, all subsequent API calls are immediate and fast!

---

## 🔑 Authentication Endpoints

* **User Register:** `POST /api/auth/register`
* **User Login:** `POST /api/auth/login`
* **Current Profile:** `GET /api/auth/me` (requires Bearer JWT token)
