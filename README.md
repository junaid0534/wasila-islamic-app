# Wasila (وَسِیْلَہ) - Modern Islamic Companion App 🌙✨

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Riverpod%20%26%20Clean-1E6050)](#architecture)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Wasila (وَسِیْلَہ)** is a modern, lightweight, and beautifully designed Islamic Companion application built with **Flutter & Riverpod**. Designed with a focus on simplicity, serenity, and everyday spiritual utility.

---

## 🎨 Theme & Design System
- **Forest Pine Green** (`#1E6050`, `#14473B`) – Serenity & Growth
- **Soft Sage Mint** (`#EBF5F1`) – Calm & Clarity
- **Luminous Warm Gold** (`#FFD54F`) – Divine Illumination
- **Crisp Typography** – Google Fonts (*Noto Nastaliq Urdu*, *Amiri*, *Scheherazade New*, *Poppins*)

---

## 🌟 Key Features

### 1. 🕌 Real-Time Prayer Times & Alarms
- Accurate daily prayer schedule (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha).
- Real-time countdown to the next prayer.
- **Zawal & Sunset Makrooh warnings** with visual alert badges.
- Dedicated **Prayer Alarms & Notifications** screen with custom Azan sounds & pre-prayer reminders (5/10/15 mins).

### 2. 📖 40 Rabbana Duas (قرآن پاک کی 40 ربَّنَا دعائیں)
- Complete collection of 40 Quranic Duas starting with *"Rabbana"*.
- **Audio Recitation** streaming by *Qari Mishary Rashid Alafasy*.
- Authentic Urdu Translation (*Fateh Muhammad Jalandhry*) & Roman transliteration toggle.
- Category filters (*Maghfirat, Hidayat, Sabar, Aulad*) + Bookmark & 1-Click Copy.

### 3. 📜 Essential Quranic Surahs
- Surah Yaseen, Al-Mulk, Ar-Rahman, Al-Waqiah, Al-Kahf, and 4 Quls.
- Customizable Arabic & Urdu font sizing with Tajweed guide.
- Verse-by-verse translation & reading mode.

### 4. 📿 Digital Smart Tasbih
- Customizable target counts (33, 99, 100, custom).
- Tactile haptic feedback and gentle click sounds.
- Preset Zikr selection (SubhanAllah, Alhamdulillah, Allahu Akbar, Astaghfirullah, etc.).

### 5. 🧭 Qibla Compass
- Smooth sensor-assisted compass pointing towards Kaaba (Makkah).
- Degrees & calibration feedback.

### 6. 💫 99 Beautiful Names of Allah & Prophet (PBUH)
- Asma-ul-Husna & Asma-un-Nabi with Arabic calligraphy, Urdu meanings, and spiritual benefits.
- Search and quick audio preview.

### 7. 🗓️ Hijri & Gregorian Calendar Integration
- Dynamic animated pill switching between Hijri date (*20 ربیع الثانی 1448*) and Gregorian AD format.
- Multi-city selector (Global & Pakistan cities) with GPS auto-detection.

---

## 🛠️ Tech Stack & Packages

- **State Management:** `flutter_riverpod`
- **Prayer Times Calculation:** `adhan`
- **Audio Engine:** `just_audio`, `audio_session`
- **Local Notifications & Exact Alarms:** `flutter_local_notifications`, `timezone`
- **Sensors & Location:** `geolocator`, `sensors_plus`
- **Storage:** `shared_preferences`
- **Typography & Animations:** `google_fonts`, `flutter_animate`, `vibration`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.16.0 or higher)
- Android SDK (API 33+ recommended)

### Installation
```bash
# 1. Clone repository
git clone https://github.com/<YOUR_USERNAME>/wasila-islamic-app.git

# 2. Navigate to project directory
cd wasila-islamic-app

# 3. Install dependencies
flutter pub get

# 4. Run on connected device or emulator
flutter run
```

---

## 📱 Android Permissions
The app includes required permissions for exact prayer alarms, notifications, and Qibla sensors:
- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- `ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION`
- `INTERNET`

---

## 🤝 Contribution & Feedback
Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a Pull Request.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
