
---

# InRida

InRida is a cross-platform car-sharing application developed with [Flutter](https://flutter.dev/) and powered by [Firebase](https://firebase.google.com/). It connects car owners with drivers, enabling owners to list their vehicles for rent and drivers to search and book available cars. The app offers role-based functionality, real-time vehicle tracking, and an intuitive user interface, making car-sharing seamless and efficient.

## Table of Contents

- [Features](#features)
- [Setup](#setup)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### For Car Owners
- **Vehicle Management**: Easily list, edit, and manage the availability of your vehicles.
- **Live Map**: Monitor the real-time locations of your fleet on an interactive map.
- **Profile Management**: Update personal details and account settings.

### For Drivers
- **Vehicle Search**: Discover available vehicles based on location and preferences.
- **Ride Management**: Track and manage ongoing and completed rides, including trip details and payment history. 
- **Profile Management**: Manage personal information and account preferences.

### General
- **Role Selection**: Choose between "Car Owner" or "Driver" roles during onboarding.
- **Authentication**: Secure login and registration using email/password or Google Sign-In.
- **Real-time Updates**: Dynamic data synchronization powered by Firestore.
- **Payment Management**: Secure and seamless payment processing using integrated payment gateways like Stripe or PayPal.

---

## Setup

Follow these steps to set up and run the InRida project locally.

### Prerequisites
- **Flutter**: Install the [Flutter SDK](https://flutter.dev/docs/get-started/install) (stable channel).
- **Firebase**: Create a [Firebase project](https://firebase.google.com/) with Authentication, Firestore, and Storage enabled.
- **Google Maps API Key**: Obtain a [Google Maps API key](https://developers.google.com/maps/documentation/android-sdk/get-api-key) for Android and iOS integration.
- A code editor (e.g., VS Code or Android Studio) and a connected device or emulator.

### Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/H-Badger009/inrida_build1.git
   cd inrida_build1
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Follow the [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview) to integrate Firebase.
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase console and place them in the appropriate directories:
     - Android: `android/app/`
     - iOS: `ios/Runner/`
   - Enable the following Firebase services:
     - Authentication (Email/Password and Google Sign-In)
     - Firestore (for real-time database)
     - Storage (for vehicle images and user data)

4. **Add Google Maps API Keys**:
   - **Android**: Insert your API key in `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <manifest ...>
       <application ...>
         <meta-data
             android:name="com.google.android.geo.API_KEY"
             android:value="YOUR_API_KEY"/>
       </application>
     </manifest>
     ```
   - **iOS**: Add your API key in `ios/Runner/AppDelegate.swift`:
     ```swift
     import GoogleMaps
     @UIApplicationMain
     @objc class AppDelegate: FlutterAppDelegate {
       override func application(...) {
         GMSServices.provideAPIKey("YOUR_API_KEY")
         return super.application(application, didFinishLaunchingWithOptions)
       }
     }
     ```

5. **Run the App**:
   ```bash
   flutter run
   ```

---

## Project Structure

The InRida codebase is organized modularly for clarity and scalability. Below is an overview of the directory structure:

```
inrida_build1/
├── android/                  # Android-specific configuration files
├── assets/                   # Static resources (images, icons, etc.)
│   ├── fonts/
│   ├── 3_dots.png
│   ├── account_icon.png
│   ├── add_car_badge.png
│   └── ...
├── ios/                      # iOS-specific configuration files
├── lib/                      # Main source code
│   ├── main.dart             # Entry point of the application
│   ├── models/               # Data models
│   │   ├── driver.dart       # Driver data structure
│   │   ├── vehicle.dart      # Vehicle data structure
│   │  
│   ├── providers/            # State management (Provider pattern)
│   │   ├── user_provider.dart
│   │   ├── vehicle_provider.dart
│   │   └── ...
│   ├── screens/              # UI screens
│   │   ├── log_in_screen.dart
│   │   ├── add_vehicle_screen.dart
│   │   └── ...
│   ├── services/             # Backend service integrations
│   │   ├── car_database_service.dart # Firestore queries and logic
│   │   └── ...
│   └── widgets/              # Reusable UI components
│       ├── profile_header.dart
│       ├── vehicle_card.dart
│       └── ...
├── pubspec.yaml              # Project dependencies and configuration
└── README.md                 # Project documentation
```

- **`assets/`**: Contains images and icons used throughout the app.
- **`models/`**: Defines data structures like `UserProfile` and `Vehicle`.
- **`providers/`**: Manages app state using the Provider package.
- **`screens/`**: Implements full-page user interfaces.
- **`services/`**: Handles interactions with Firebase services.
- **`widgets/`**: Stores reusable UI building blocks.

---

## Usage

### Onboarding
- Launch the app and select your role: "Car Owner" or "Driver".
- Register a new account or log in using email/password or Google Sign-In.

### Car Owners
- **Add Vehicles**: Navigate to the "Add Vehicle" screen to list a new vehicle with details like make, model, and availability.
- **Manage Fleet**: Update vehicle statuses and monitor their locations on the live map.
- **Profile**: Edit personal information and preferences in the profile section.

### Drivers
- **Search Vehicles**: Browse available vehicles by location and filter based on preferences.
- **View Details**: Inspect vehicle specifics, such as images and rental terms.
- **Profile**: Manage account settings and personal details.

---

## Contributing

We welcome contributions to enhance InRida! To get started:

1. **Fork the Repository**: Create your own copy of the project.
2. **Create a Branch**: Work on your feature or bug fix in a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Commit Changes**: Write clear, concise commit messages.
4. **Submit a Pull Request**: Provide a detailed description of your changes for review.

Please adhere to the [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style) and ensure your code is well-documented and tested. Report issues or suggest improvements via the repository's issue tracker.

---

## License

InRida is licensed under the [MIT License](LICENSE). See the [LICENSE](LICENSE) file for more details.

---

**Disclaimer**: InRida is a prototype developed for educational purposes. It is not intended for production use without additional development, testing, and security enhancements.

---

Built using [Flutter](https://flutter.dev/) and [Firebase](https://firebase.google.com/). Special thanks to the open-source community for their invaluable libraries and tools.

--- 