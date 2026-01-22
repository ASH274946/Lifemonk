# Lifemonk 🧘‍♂️🎓

Lifemonk <https://lifemonk.vercel.app/>  is a modern EdTech ecosystem designed to transform the learning experience for children through gamification. By merging a powerful React-based web dashboard with a versatile Flutter mobile application, Lifemonk provides a seamless, cross-platform journey for both students and educators.

---

## 🌟 Key Features

### 🖥️ Web Application (Dashboard)
* **Responsive Design:** Fully optimized for desktops, tablets, and mobile browsers.
* **Theming:** Native support for Dark and Light modes.
* **Interactive UI:** Fluid transitions and animations powered by Framer Motion.
* **Student Analytics:** (Placeholder for progress tracking features).

### 📱 Mobile Application
* **Cross-Platform:** High-performance app built with Flutter.
* **Easy Onboarding:** Secure login via Google Sign-In and Phone OTP.
* **On-the-go Learning:** Access gamified modules anywhere.

### 🔐 Backend & Security
* **Real-time Database:** Powered by Supabase for instant data synchronization.
* **Secure Auth:** Robust identity management using Twilio SMS and Google OAuth.

---

## 🛠️ Tech Stack

### Frontend & Web
| Technology | Usage |
| :--- | :--- |
| **React (Vite)** | Core Web Framework |
| **Tailwind CSS** | Utility-first Styling |
| **Framer Motion** | UI Animations |
| **Vercel** | Hosting & Deployment |

### Mobile
| Technology | Usage |
| :--- | :--- |
| **Flutter** | Mobile Framework |
| **Dart** | Programming Language |
| **Twilio** | SMS Gateway (OTP) |

### Backend
| Technology | Usage |
| :--- | :--- |
| **Supabase** | PostgreSQL Database & Auth |
| **PL/pgSQL** | Database Functions & Triggers |

---

## 🏗️ Project Architecture



The project is structured as a monorepo for easier management of the dual-platform ecosystem:

```
Lifemonk/
├── mobile_application/   # Flutter project for iOS & Android
├── web_application/      # React project for the web dashboard
├── twilio_setup_guide.md # Technical guide for SMS integration
└── README.md             # Project documentation
```

# 📱 Twilio & Supabase Auth Setup Guide

This guide explains how to configure Twilio with Supabase to enable Phone (SMS) Authentication for the Lifemonk mobile application.

## 1. Twilio Configuration
1. **Create an Account:** Sign up at [Twilio](https://www.twilio.com/).
2. **Get a Phone Number:** Buy a Twilio phone number with SMS capabilities.
3. **Account Credentials:** From your Twilio Console, copy the following:
   - `Account SID`
   - `Auth Token`
4. **Create a Messaging Service:**
   - Go to **Messaging > Services**.
   - Create a new service and add your Twilio number to the Sender Pool.
   - Copy the `Messaging Service SID`.

## 2. Supabase Configuration
1. **Navigate to Auth Settings:** Go to your Supabase Project Dashboard > **Authentication > Providers**.
2. **Enable Phone:** Toggle the "Phone" provider to **ON**.
3. **SMS Provider:** Select `Twilio` from the dropdown.
4. **Fill in Credentials:**
   - Paste your `Twilio Account SID`.
   - Paste your `Twilio Auth Token`.
   - Paste your `Twilio Message Service SID`.
5. **Save Changes.**

## 3. Environment Variables
Update the `.env` file in your `mobile_application` folder with your Supabase URL and Anon Key to ensure the Flutter app can communicate with the backend.

## 4. Testing
- Use the "Test OTP" feature in Supabase to verify the connection.
- Ensure your Twilio account has enough balance/credits to send SMS.
- If using a **Twilio Trial Account**, you must verify your own phone number in the Twilio Console before you can receive an OTP.

# MIT License

Copyright (c) 2026 ASH274946

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
