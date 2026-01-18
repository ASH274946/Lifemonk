# Architecture Overview

## Project Structure

LifeMonk follows Clean Architecture principles with a feature-based organization:

```
lib/
├── core/                 # Core functionality
│   ├── constants/       # App-wide constants
│   ├── router/          # Navigation configuration
│   ├── theme/           # Theme and styling
│   └── utils/           # Utility functions
├── features/            # Feature modules
│   ├── auth/           # Authentication
│   ├── home/           # Home screen
│   ├── onboarding/     # Onboarding flow
│   └── ...
└── shared/             # Shared components
    ├── services/       # Services (Supabase, storage)
    ├── widgets/        # Reusable widgets
    └── cms/            # CMS integration
```

## Architectural Layers

### 1. Presentation Layer

- **Screens**: UI components for user interaction
- **Widgets**: Reusable UI components
- **Providers**: State management using Riverpod

### 2. Domain Layer

- **Models**: Business entities
- **State**: Application state definitions

### 3. Data Layer

- **Repositories**: Data access abstraction
- **Services**: External service integrations (Supabase, Local Storage)

## Design Patterns

### Repository Pattern

Abstracts data sources and provides a clean API:

```dart
abstract class AuthRepository {
  Future<Result<User>> signIn(String phone);
  Future<Result<void>> verifyOtp(String phone, String code);
}
```

### Provider Pattern (Riverpod)

State management and dependency injection:

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
```

### Result Pattern

Type-safe error handling:

```dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
}
class Failure<T> extends Result<T> {
  final String error;
}
```

## Navigation

Uses `go_router` for declarative routing:

- Route guards for authentication
- Deep linking support
- Type-safe navigation

## State Management

Riverpod for predictable state management:

- `StateNotifierProvider` for complex state
- `FutureProvider` for async data
- `Provider` for dependency injection

## Data Flow

1. User interacts with UI (Presentation)
2. Widget calls Provider method
3. Provider calls Repository
4. Repository calls Service (Supabase/Local Storage)
5. Service returns data
6. Repository transforms data to Domain models
7. Provider updates state
8. UI rebuilds with new state

## Testing Strategy

- **Unit Tests**: Test business logic in isolation
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

## Best Practices

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Dependency Inversion**: Depend on abstractions, not implementations
3. **Single Responsibility**: Each class has one reason to change
4. **Immutability**: Use immutable data structures
5. **Type Safety**: Leverage Dart's type system
