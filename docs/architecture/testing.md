# Automated Testing Patterns

## Test File Organization

```
packages/features/sign_in/
└── test/
    ├── sign_in_cubit_test.dart        # Cubit unit tests
    └── widgets/
        └── sign_in_screen_test.dart   # Widget tests

packages/quote_repository/
└── test/
    ├── quote_repository_test.dart     # Repository unit tests
    ├── mappers_test.dart              # Mapper unit tests
    └── quote_repository_test.mocks.dart  # Generated mocks (DO NOT EDIT)
```

## Cubit/Bloc Testing with bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('SignInCubit', () {
    blocTest<SignInCubit, SignInState>(
      'emits unvalidated email when email changes for the first time',
      build: () => SignInCubit(userRepository: mockUserRepository),
      act: (cubit) => cubit.onEmailChanged('test@email.com'),
      expect: () => [
        const SignInState(email: Email.unvalidated('test@email.com')),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits validated email when email unfocused',
      build: () => SignInCubit(userRepository: mockUserRepository),
      seed: () => const SignInState(email: Email.unvalidated('invalid')),
      act: (cubit) => cubit.onEmailUnfocused(),
      expect: () => [
        const SignInState(email: Email.validated('invalid')),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits success when sign in succeeds',
      build: () {
        when(() => mockUserRepository.signIn(any(), any()))
            .thenAnswer((_) async {});
        return SignInCubit(userRepository: mockUserRepository);
      },
      seed: () => const SignInState(
        email: Email.validated('test@email.com'),
        password: Password.validated('12345'),
      ),
      act: (cubit) => cubit.onSubmit(),
      expect: () => [
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.inProgress,
        ),
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.success,
        ),
      ],
    );

    blocTest<SignInCubit, SignInState>(
      'emits invalidCredentialsError when sign in throws InvalidCredentialsException',
      build: () {
        when(() => mockUserRepository.signIn(any(), any()))
            .thenThrow(InvalidCredentialsException());
        return SignInCubit(userRepository: mockUserRepository);
      },
      seed: () => const SignInState(
        email: Email.validated('test@email.com'),
        password: Password.validated('12345'),
      ),
      act: (cubit) => cubit.onSubmit(),
      expect: () => [
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.inProgress,
        ),
        isA<SignInState>().having(
          (s) => s.submissionStatus, 'status', SubmissionStatus.invalidCredentialsError,
        ),
      ],
    );
  });
}
```

## Repository Testing

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FavQsApi, QuoteLocalStorage])
void main() {
  late MockFavQsApi mockApi;
  late MockQuoteLocalStorage mockStorage;
  late QuoteRepository repository;

  setUp(() {
    mockApi = MockFavQsApi();
    mockStorage = MockQuoteLocalStorage();
    repository = QuoteRepository(
      remoteApi: mockApi,
      localStorage: mockStorage,  // Inject mock via @visibleForTesting parameter
    );
  });

  group('getQuoteListPage', () {
    test('returns cached data with cachePreferably when cache exists', () async {
      when(() => mockStorage.getPage(1, false))
          .thenAnswer((_) async => cachedPageCM);

      final result = await repository.getQuoteListPage(
        1,
        fetchPolicy: QuoteListPageFetchPolicy.cachePreferably,
      ).first;

      expect(result, equals(expectedDomainPage));
      verifyNever(() => mockApi.getQuoteListPage(any()));
    });

    test('calls API with networkOnly policy', () async {
      when(() => mockApi.getQuoteListPage(1))
          .thenAnswer((_) async => apiPageRM);
      when(() => mockStorage.upsertPage(any(), any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.getQuoteListPage(
        1,
        fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
      ).first;

      expect(result, equals(expectedDomainPage));
      verify(() => mockApi.getQuoteListPage(1)).called(1);
    });
  });
}
```

## Mapper Testing

```dart
void main() {
  group('QuoteCM to Domain', () {
    test('maps all fields correctly', () {
      final cachModel = QuoteCM(
        id: 1,
        body: 'Test quote',
        author: 'Author',
        isFavorite: true,
      );

      final result = cacheModel.toDomainModel();

      expect(result.id, equals(1));
      expect(result.body, equals('Test quote'));
      expect(result.author, equals('Author'));
      expect(result.isFavorite, isTrue);
    });
  });

  group('DarkModePreferenceCM to Domain', () {
    test('maps alwaysDark correctly', () {
      expect(
        DarkModePreferenceCM.alwaysDark.toDomain(),
        equals(DarkModePreference.alwaysDark),
      );
    });
  });
}
```

## Widget Testing

```dart
void main() {
  testWidgets('SignInScreen renders all form fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          SignInLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: SignInScreen(
          userRepository: MockUserRepository(),
          onSignInSuccess: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));  // Email + Password
    expect(find.byType(ExpandedElevatedButton), findsOneWidget);
  });

  testWidgets('shows error snackbar on invalid credentials', (tester) async {
    // Setup cubit to emit error state
    await tester.pumpWidget(/* ... */);
    await tester.tap(find.byType(ExpandedElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
```

## Mock Generation

Use `@GenerateMocks` annotation and run `make build-runner` to generate mock classes:

```dart
@GenerateMocks([UserRepository, FavQsApi, QuoteLocalStorage])
void main() { /* tests */ }
```

This generates `*.mocks.dart` files. NEVER edit generated mock files manually.

## Running Tests

```bash
make testing          # Run ALL tests across all packages
make test-coverage    # Run tests with coverage reports
```
