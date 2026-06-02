# 🛡️ SurakshaDrive — Driver Drowsiness Detection

![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.15-orange?logo=tensorflow)
![Android](https://img.shields.io/badge/Android-14-green?logo=android)
![Status](https://img.shields.io/badge/Status-Phase%204A%20Complete-brightgreen)

> **Suraksha (सुरक्षा) = Safety in Hindi.**
> A real-time driver drowsiness detection app built for Indian gig economy drivers — Uber, Ola, Rapido — who drive long shifts with zero safety net. Runs **100% offline**. No internet required.

---

## 🚨 The Problem

Thousands of road accidents every year are caused by driver fatigue. Gig economy drivers often drive 10–12 hour shifts with no safety mechanism in place. SurakshaDrive aims to fix that with a lightweight, offline-first AI system that monitors driver alertness in real time.

> *Previously known as DriveSafe — renamed to SurakshaDrive to better connect with Indian drivers.*

---

## 🗺️ Project Roadmap

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 1** | MediaPipe + EAR algorithm — laptop webcam prototype | ✅ Complete |
| **Phase 2** | Custom CNN training on MRL Eye Dataset (48,000 images) | ✅ Complete |
| **Phase 3** | MediaPipe + CNN ensemble — dual verification system | ✅ Complete |
| **Phase 4A** | Flutter Android app — complete UI with all screens | ✅ Complete |
| **Phase 4B** | CNN model integration into live camera feed | 🔄 In Progress |
| **Phase 4C** | Google Maps integration + background service | ⏳ Upcoming |
| **Phase 4D** | Play Store deployment | ⏳ Upcoming |

---

## 📂 Repository Structure

```
DriverSafe/
├── ml/
│   └── phases/
│       ├── phase1/
│       │   ├── drivesafe_phase1.py       # MediaPipe EAR detection
│       │   └── drivesafe_phase3.py       # EAR + CNN ensemble
│       ├── phase2/
│       │   └── DriveSafe_Phase2.ipynb    # CNN training (Google Colab)
│       ├── models/
│       │   └── drivesafe_float16.tflite  # Trained model — 513 KB
│       ├── requirements.txt
│       └── README.md
├── lib/                          # Flutter app source
│   ├── main.dart
│   ├── theme.dart                # AppColors — light/dark
│   └── screens/
│       ├── splash_screen.dart
│       ├── onboarding_screen.dart
│       ├── main_screen.dart      # Bottom navigation
│       ├── home_screen.dart      # Camera + EAR feed
│       ├── alert_screen.dart     # जागो! रुको! alert
│       ├── analytics_screen.dart
│       └── settings_screen.dart
├── assets/
│   ├── models/                   # TFLite model
│   ├── audio/                    # Alarm sound
│   └── icon/                     # App icon
├── pubspec.yaml
└── README.md
```

---

## 📱 Phase 4A — Flutter App

A complete Android app with production-ready UI built from scratch.

### Screens

| Screen | Description |
|--------|-------------|
| **Splash** | Animated eye logo with warm glow |
| **Onboarding** | 4 slides — AI detection, privacy, alerts, battery |
| **Home** | Live camera feed, EAR value, Connect with Maps |
| **Alert** | Full red screen — जागो! रुको! + vibration + alarm |
| **Analytics** | Session history, drive time, avg EAR |
| **Settings** | Dark mode, EAR sensitivity, language, sound/vibration |

### Design System

| Property | Value |
|----------|-------|
| Primary color | Saffron `#FF9500` |
| Light background | `#F2F2F7` |
| Dark background | `#1C1C1E` slate |
| Card surface | `#FFFFFF` / `#2C2C2E` |
| Safe color | `#30D158` green |
| Alert color | `#FF453A` red |
| Font | Inter (Google Fonts) |

### Features
- ✅ Light mode default + instant dark mode toggle
- ✅ Bottom navigation — Home, Alert, Analytics, Settings
- ✅ Live front camera feed (3:4 ratio, rounded corners)
- ✅ LIVE dot + FPS overlay on camera
- ✅ जागो! रुको! full screen alert in Hindi
- ✅ Looping alarm sound until dismissed
- ✅ Continuous vibration pattern on alert
- ✅ EAR sensitivity slider in settings
- ✅ Hindi / English language toggle
- ✅ 100% offline — no internet required

---

## 🧠 Phase 2 — CNN Model Results

| Metric | Result |
|--------|--------|
| Dataset | MRL Eye Dataset — 48,000 images |
| Test Accuracy | **99.71%** |
| Test AUC | **0.9999** |
| Model size (TFLite float16) | **513 KB** |
| Training platform | Google Colab T4 GPU |
| Best epoch | 25 / 30 |

---

## 🔗 Phase 3 — EAR + CNN Ensemble

```
Webcam Frame
      ↓
MediaPipe Face Mesh (468 landmarks)
      ↓
Extract Eye Region
   ↙        ↘
EAR          CNN Model (TFLite)
Algorithm    513KB on-device
   ↓               ↓
EAR < 0.20?   CNN < threshold?
   ↘        ↙
  Either triggers?
       ↓
  Alarm + Warning
```

**Running at 30 FPS on laptop CPU. Zero false alarms after threshold tuning.**

---

## 🛠️ Setup

### Phase 1 — Laptop Webcam (VS Code)

```bash
git clone https://github.com/parthrkunkunkar-ds/DriverSafe.git
cd DriverSafe

py -3.10 -m venv .venv
.venv\Scripts\activate

pip install opencv-python==4.10.0.84 mediapipe==0.10.14 numpy==1.26.4 pygame==2.6.1 tensorflow-cpu==2.15.0 protobuf==4.25.9

python phase1/drivesafe_phase1.py   # Phase 1 — EAR only
python phase1/drivesafe_phase3.py   # Phase 3 — EAR + CNN
```

### Phase 4 — Flutter Android App

```bash
# Requirements: Flutter 3.29.3, Android Studio, Android phone

cd DriverSafe
flutter pub get
flutter run
```

**Prerequisites:**
- Flutter 3.29.3
- Android phone with Developer Mode enabled
- USB Debugging on

---

## 🧰 Tech Stack

| Tool | Purpose |
|------|---------|
| Python 3.10 | Phase 1 & 3 — laptop detection |
| MediaPipe 0.10.14 | Face mesh + landmark detection |
| OpenCV 4.10 | Webcam capture + frame processing |
| TensorFlow CPU 2.15 | TFLite inference |
| Flutter 3.29.3 | Android app framework |
| Google Fonts (Inter) | Typography |
| camera package | Front camera feed |
| tflite_flutter | On-device CNN inference |
| audioplayers | Alarm sound |
| vibration | Haptic feedback |
| shared_preferences | Settings persistence |
| Google Colab T4 GPU | CNN model training |

---

## 📊 Achieved vs Target

| Metric | Target | Achieved |
|--------|--------|----------|
| CNN Accuracy | > 95% | **99.71%** ✅ |
| AUC | > 0.98 | **0.9999** ✅ |
| Inference speed | 24+ fps | **30 FPS** ✅ |
| Model size | < 1MB | **513 KB** ✅ |
| Internet required | None | **None** ✅ |

---

## 🔭 What's Coming Next

**Phase 4B** — Wiring the 99.71% accurate CNN model into the live Flutter camera feed. Real drowsiness detection on Android.

**Phase 4C** — Google Maps integration so drivers don't need to switch between apps. Background service so detection runs even when screen is off.

**Phase 4D** — Play Store deployment.

---

## 👨‍💻 Author

**Parth Kunkunkar**
🔗 [LinkedIn](https://www.linkedin.com/in/parthkunkunkar/)
⭐ [GitHub](https://github.com/parthrkunkunkar-ds/DriverSafe)

---

> *This is not a tutorial project. This is a real system being built for real drivers.*
>
> *Apni suraksha, apne haath — आपनी सुरक्षा, अपने हाथ*
