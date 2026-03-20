# State Management with Cubits & Blocs

## When to Use Cubit vs Bloc

| Use Cubit | Use Bloc |
|-----------|----------|
| Simple screens with direct method calls | Complex screens with many event types |
| Form validation and submission | Pagination with infinite scroll |
| Single-responsibility screens | Screens combining search + filters + refresh |
| Detail views | Screens needing event debouncing/throttling |
| CRUD operations | Screens combining multiple data streams |

## Cubit Implementation Pattern

```dart
class QuoteDetailsCubit extends Cubit<QuoteDetailsState> {
  QuoteDetailsCubit({
    required this.quoteId,
    required this.quoteRepository,
  }) : super(const QuoteDetailsInProgress()) {
    _fetchQuoteDetails();  // Trigger initial load from constructor
  }

  final int quoteId;
  final QuoteRepository quoteRepository;

  Future<void> _fetchQuoteDetails() async {
    try {
      final quote = await quoteRepository.getQuoteDetails(quoteId);
      emit(QuoteDetailsSuccess(quote: quote));
    } catch (error) {
      emit(QuoteDetailsFailure());
    }
  }

  // Side-effect action: Keep success state visible, show error via snackbar
  Future<void> upvoteQuote() async {
    final currentQuote = state is QuoteDetailsSuccess
        ? (state as QuoteDetailsSuccess).quote : null;
    if (currentQuote == null) return;

    try {
      final updatedQuote = await quoteRepository.upvoteQuote(currentQuote.id);
      emit(QuoteDetailsSuccess(quote: updatedQuote));
    } catch (error) {
      emit(QuoteDetailsSuccess(quote: currentQuote)); // Re-emit to trigger listener
    }
  }
}
```

## State Class Patterns

**Option A: Inheritance-based (for loading/success/failure screens)**

Use when a screen has clearly distinct visual states:

```dart
abstract class QuoteDetailsState extends Equatable {
  const QuoteDetailsState();

  @override
  List<Object?> get props => [];
}

class QuoteDetailsInProgress extends QuoteDetailsState {
  const QuoteDetailsInProgress();
}

class QuoteDetailsSuccess extends QuoteDetailsState {
  const QuoteDetailsSuccess({required this.quote});
  final Quote quote;

  @override
  List<Object?> get props => [quote];
}

class QuoteDetailsFailure extends QuoteDetailsState {
  const QuoteDetailsFailure();
}
```

**Option B: Single class with copyWith (for forms and complex states)**

Use when state has many fields that change independently:

```dart
class SignInState extends Equatable {
  const SignInState({
    this.email = const Email.unvalidated(),
    this.password = const Password.unvalidated(),
    this.submissionStatus = SubmissionStatus.idle,
  });

  final Email email;
  final Password password;
  final SubmissionStatus submissionStatus;

  SignInState copyWith({
    Email? email,
    Password? password,
    SubmissionStatus? submissionStatus,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [email, password, submissionStatus];
}
```

## SubmissionStatus Enum

Always use this enum for tracking form/action submission states:

```dart
enum SubmissionStatus {
  idle,
  inProgress,
  success,
  genericError,
  invalidCredentialsError,  // Feature-specific errors as needed
  emailAlreadyRegisteredError,
  usernameAlreadyTakenError,
}

extension SubmissionStatusX on SubmissionStatus {
  bool get isError => this == SubmissionStatus.genericError ||
      this == SubmissionStatus.invalidCredentialsError ||
      this == SubmissionStatus.emailAlreadyRegisteredError ||
      this == SubmissionStatus.usernameAlreadyTakenError;
}
```

## Bloc Implementation Pattern

```dart
class QuoteListBloc extends Bloc<QuoteListEvent, QuoteListState> {
  QuoteListBloc({
    required this.quoteRepository,
    required this.userRepository,
  }) : super(const QuoteListState()) {
    _registerEventHandlers();
    add(const QuoteListStarted());  // Trigger initial load
  }

  final QuoteRepository quoteRepository;
  final UserRepository userRepository;

  void _registerEventHandlers() {
    on<QuoteListStarted>(_handleStarted);
    on<QuoteListSearchTermChanged>(
      _handleSearchTermChanged,
      transformer: restartable(),  // Cancel previous search on new input
    );
    on<QuoteListNextPageRequested>(_handleNextPageRequested);
    on<QuoteListRefreshed>(_handleRefreshed);
    on<QuoteListTagChanged>(_handleTagChanged);
    on<QuoteListItemFavoriteToggled>(_handleFavoriteToggled);
  }

  Future<void> _handleStarted(
    QuoteListStarted event,
    Emitter<QuoteListState> emit,
  ) async {
    await emit.onEach(
      userRepository.getUser(),
      onData: (user) {
        // React to user changes
        add(QuoteListUsernameObtained(username: user?.username));
      },
    );
  }
}
```

## Event Classes

```dart
abstract class QuoteListEvent extends Equatable {
  const QuoteListEvent();

  @override
  List<Object?> get props => [];
}

class QuoteListStarted extends QuoteListEvent {
  const QuoteListStarted();
}

class QuoteListSearchTermChanged extends QuoteListEvent {
  const QuoteListSearchTermChanged(this.searchTerm);
  final String searchTerm;

  @override
  List<Object?> get props => [searchTerm];
}

class QuoteListNextPageRequested extends QuoteListEvent {
  const QuoteListNextPageRequested({required this.pageNumber});
  final int pageNumber;

  @override
  List<Object?> get props => [pageNumber];
}
```

## Event Transformers

Use event transformers for controlling event processing:

```dart
// Debounce search input (wait for user to stop typing)
on<QuoteListSearchTermChanged>(
  _handleSearchTermChanged,
  transformer: debounce(const Duration(seconds: 1)),
);

// Cancel previous operation when new one arrives (search, filter changes)
on<QuoteListSearchTermChanged>(
  _handleSearchTermChanged,
  transformer: restartable(),
);

// Process events sequentially (pagination)
on<QuoteListNextPageRequested>(
  _handleNextPageRequested,
  transformer: sequential(),
);
```

## UI Integration: BlocProvider, BlocBuilder, BlocConsumer

**BlocProvider** — Provides Cubit/Bloc instance to widget tree:
```dart
BlocProvider<SignInCubit>(
  create: (_) => SignInCubit(userRepository: userRepository),
  child: const SignInView(),
)
```

**BlocBuilder** — Rebuilds UI when state changes:
```dart
BlocBuilder<QuoteDetailsCubit, QuoteDetailsState>(
  builder: (context, state) {
    if (state is QuoteDetailsSuccess) {
      return QuoteView(quote: state.quote);
    } else if (state is QuoteDetailsFailure) {
      return const ExceptionIndicator();
    }
    return const CenteredCircularProgressIndicator();
  },
)
```

**BlocConsumer** — Combines BlocBuilder + BlocListener (use when you need both UI rebuild AND side effects):
```dart
BlocConsumer<SignInCubit, SignInState>(
  listenWhen: (oldState, newState) =>
      oldState.submissionStatus != newState.submissionStatus,
  listener: (context, state) {
    if (state.submissionStatus == SubmissionStatus.success) {
      widget.onSignInSuccess();
    } else if (state.submissionStatus.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        state.submissionStatus == SubmissionStatus.invalidCredentialsError
            ? SnackBar(content: Text(l10n.invalidCredentialsErrorMessage))
            : const GenericErrorSnackBar(),
      );
    }
  },
  builder: (context, state) {
    // Build form UI based on state
  },
)
```

## Error Display Strategy

| Scenario | Pattern |
|----------|---------|
| Data fetch fails (no data to show) | Emit failure state → show `ExceptionIndicator` widget |
| Side-effect fails (data still visible) | Re-emit success state → show SnackBar via `BlocListener` |
| Form submission fails | Emit error submissionStatus → show SnackBar via `BlocListener` |
