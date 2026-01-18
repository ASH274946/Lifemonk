# Twilio SMS Authentication Setup Guide

This guide explains how to switch from Supabase Test Phone Numbers to real SMS verification using Twilio.

## 1. Create a Twilio Account
1.  Go to [Twilio.com](https://www.twilio.com/) and sign up for an account.
2.  Verify your own phone number during sign-up.

## 2. Get Credentials
1.  Log in to the **Twilio Console Dashboard**.
2.  Scroll down to the **"Account Info"** section.
3.  Locate and copy the following:
    *   **Account SID** (starts with `AC...`)
    *   **Auth Token** (click "show" to see it)

## 2.1 Create Messaging Service (Required)
1.  In Twilio Console, search for **"Messaging Services"** in the top bar.
2.  Click **"Create Messaging Service"**.
3.  Name it (e.g., "Lifemonk Auth") and select "Notify my users" as the use case.
4.  Proceed through the setup (you can skip adding senders for now strictly for getting the SID, but eventually you need a phone number added to it).
5.  Once created, copy the **Messaging Service SID** (starts with `MG...`).

## 3. Configure Supabase
1.  Go to your [Supabase Dashboard](https://supabase.com/dashboard).
2.  Navigate to **Authentication** -> **Providers** -> **Phone**.
3.  Ensure **"Enable Phone provider"** is toggled ON.
4.  Under **"SMS provider"**, select **Twilio** from the dropdown.
5.  Paste your **Account SID** and **Auth Token** into the respective fields.
6.  (Optional) If you have a specific **Message Service SID** from Twilio, enter it. Otherwise, leave it blank.
7.  Click **Save**.

## 4. Disabling Test Numbers (Optional)
Once Twilio is live, you can remove your test numbers:
1.  In the same **Phone** provider settings, scroll down to **"Phone Numbers"**.
2.  Delete the test numbers (e.g., `+918885777104`) to prevent them from bypassing the real SMS check.

## 5. Usage
No code changes are required in the app! The same `_signInWithPhone` method will now trigger Supabase to send a real SMS via Twilio instead of accepting the test OTP.
