# LifeMonk API Documentation

## Authentication Endpoints

### Phone OTP Authentication

#### Send OTP

```dart
// Send OTP to phone number
await supabase.auth.signInWithOtp(
  phone: phoneNumber,
);
```

#### Verify OTP

```dart
// Verify OTP code
await supabase.auth.verifyOTP(
  phone: phoneNumber,
  token: otpCode,
  type: OtpType.sms,
);
```

## Database Schema

### Users Table

- `id` (UUID, Primary Key)
- `phone` (String)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### Student Profiles Table

- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key)
- `name` (String)
- `class_level` (String)
- `learning_goals` (Array<String>)
- `parent_name` (String, Optional)
- `parent_phone` (String, Optional)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### Focus Sessions Table

- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key)
- `title` (String)
- `duration` (Integer, minutes)
- `completed` (Boolean)
- `created_at` (Timestamp)

## State Management

### Auth Provider

Handles authentication state using Riverpod:

- `authProvider`: Current authentication state
- `authRepositoryProvider`: Authentication operations

### Home Provider

Manages home screen data:

- `homeProvider`: Home screen state
- `homeRepositoryProvider`: Data fetching operations

## Error Handling

All API calls return Result types:

```dart
final result = await authRepository.signIn(phone);
result.when(
  success: (data) => // Handle success,
  failure: (error) => // Handle error,
);
```

## Environment Variables

Required environment variables:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
