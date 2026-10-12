# EV Charging & Navigation App

EV Charging & Navigation App is a modern, feature-rich cross-platform mobile application built with **Flutter** designed to streamline the electric vehicle (EV) charging experience. It features real-time traffic-aware routing, proximity-based geofencing, custom dark-themed maps, and a secure multi-tab ecosystem.

---

## 🚀 Key Features

*   **Interactive Dark-Themed Maps:** Integrates Google Maps SDK styled with a custom JSON dark mode configuration (`#212121` palette) for a sleek, modern driver interface.
*   **Live Traffic-Aware Routing:** Powered by the **Google Routes API (V2)** and `flutter_polyline_points`, calculating precise turn-by-turn polylines that hug real-world road geometries while accounting for live congestion and providing dynamic ETAs.
*   **"Find Nearest" Quick Action:** Instantly computes spherical distances using the Haversine formula across available charging hubs to locate and route the driver to the closest station with a single tap.
*   **Proximity-Based Geofencing:** Enforces safety logic by calculating real-time displacement from the vehicle to the station pin. Dynamically locks/unlocks the **"Start Charging"** button (displaying *"Drive Closer To Charge"* if the user is further than 200 meters away).
*   **Secure API Key Management:** Implements best practices by shielding sensitive credentials using `flutter_dotenv` for Dart services and `local.properties` / `AndroidManifest.xml` injection for native Android builds.
*   **State-Preserving Navigation Shell:** Built using an optimized `IndexedStack` layout across major app sections (Home, Map, Charge, History, Wallet, Profile) to prevent state loss during tab switching.

---

## 📱 Tech Stack used in the project

*   **Framework:** Flutter / Dart
*   **Mapping & Navigation:** `google_maps_flutter`, `flutter_polyline_points`
*   **Backend & State:** Firebase Core, Provider
*   **Environment Security:** `flutter_dotenv`

---

## 🛠️ Getting Started & Installation

Follow these steps to set up and run the project locally on your machine.

### 1. Prerequisites
*   Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   An active **Google Cloud Console** account with the following APIs enabled:
    *   Maps SDK for Android / iOS
    *   Routes API (V2)

### 2. Clone the Repository
```bash
git clone [https://github.com/your-username/ev-charging-app.git](https://github.com/your-username/ev-charging-app.git)
cd ev-charging-app