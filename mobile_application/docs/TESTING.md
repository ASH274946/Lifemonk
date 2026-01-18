# Testing Guide

## Overview

LifeMonk uses a comprehensive testing strategy to ensure code quality and reliability.

## Test Types

### 1. Unit Tests

Test individual functions and classes in isolation.

```dart
// Example unit test
void main() {
  group('PhoneValidator', () {
    test('should validate correct phone number', () {
      expect(PhoneValidator.isValid('+911234567890'), true);
    });

    test('should reject invalid phone number', () {
      expect(PhoneValidator.isValid('123'), false);
    });
  });
}
```

### 2. Widget Tests

Test UI components and their interactions.

```dart
void main() {
  testWidgets('Login button shows loading indicator', (tester) async {
    await tester.pumpWidget(MyApp());

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### 3. Integration Tests

Test complete user flows.

```dart
void main() {
  testWidgets('Complete authentication flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Enter phone number
    await tester.enterText(find.byType(TextField), '+911234567890');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();

    // Enter OTP
    await tester.enterText(find.byType(PinCodeTextField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    // Verify navigation to home
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

## Running Tests

### Run all tests

```bash
flutter test
```

### Run specific test file

```bash
flutter test test/features/auth/auth_repository_test.dart
```

### Run tests with coverage

```bash
flutter test --coverage
```

### View coverage report

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Structure

```
test/
├── features/
│   ├── auth/
│   │   ├── auth_repository_test.dart
│   │   └── auth_provider_test.dart
│   ├── home/
│   │   └── home_screen_test.dart
│   └── ...
├── core/
│   ├── utils/
│   │   └── validators_test.dart
│   └── ...
└── integration/
    └── app_test.dart
```

## Mocking

Use `mockito` or `mocktail` for mocking dependencies:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  test('should call repository when signing in', () async {
    when(() => mockAuthRepository.signIn(any()))
        .thenAnswer((_) async => Success(user));

    final notifier = AuthNotifier(mockAuthRepository);
    await notifier.signIn('+911234567890');

    verify(() => mockAuthRepository.signIn('+911234567890')).called(1);
  });
}
```

## Best Practices

1. **Test Naming**: Use descriptive names that explain what is being tested
2. **Arrange-Act-Assert**: Structure tests clearly
3. **Test Independence**: Each test should be independent
4. **Mock External Dependencies**: Don't make real API calls in tests
5. **Coverage Goal**: Aim for 80%+ code coverage
6. **Fast Tests**: Keep unit tests fast (< 100ms per test)

## Continuous Testing

Run tests before:

- Committing code
- Creating pull requests
- Merging to main branch

## Test Coverage Goals

- **Core utilities**: 90%+
- **Business logic**: 80%+
- **UI widgets**: 70%+
- **Overall**: 75%+

## Common Testing Patterns

### Testing Async Code

```dart
test('async function', () async {
  final result = await fetchData();
  expect(result, expectedValue);
});
```

### Testing Streams

```dart
test('stream emits values', () {
  expectLater(
    myStream,
    emitsInOrder([value1, value2, value3]),
  );
});
```

### Testing Errors

```dart
test('throws exception', () {
  expect(
    () => functionThatThrows(),
    throwsA(isA<CustomException>()),
  );
});
```
