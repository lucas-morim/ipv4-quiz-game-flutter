# IPv4 Quiz Game 🎮

[![Flutter](https://img.shields.io/badge/Flutter-3.13.8-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

An educational game designed to test knowledge about **IPv4 addressing, subnetting, and network masks**, developed in **Flutter**.

---

## 📌 Features

- **Authentication System**:
  - User login and registration  
  - Guest mode  
  - Session management with Provider  

- **Level-Based Quizzes**:
  - ✅ Easy (Masks /8, /16, /24) — Timer: 30s, 3 lives  
  - ⚠️ Medium (Various subnets) — Timer: 20s, 3 lives  
  - 💀 Hard (Supernets and aggregation) — Timer: 10s, 3 lives  

- **User Profile**:
  - View statistics  
  - Edit user information  
  - Score history  

- **Global Ranking**:
  - Top 5 players per level  
  - Compare your performance  

---

## 🛠️ Technologies Used

| Technology | Description |
|-------------|-------------|
| **Flutter 3.13** | Cross-platform framework |
| **Provider** | State management |
| **SQFlite** | Local SQLite database |
| **Dart 3.1** | Programming language |

---

## 🚀 How to Run

1. **Prerequisites**:
   - Flutter SDK (version **3.13.8** or higher)  
   - Configured device or emulator  

2. **Installation**:
   ```bash
   git clone https://github.com/lucas-morim/ipv4-quiz-game.git
   cd ipv4-quiz-game
   flutter pub get
