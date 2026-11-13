import 'package:domain_models/domain_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwf_architecture_boiler_plate/app_session.dart';

import 'helpers/fake_user_repository.dart';

void main() {
  const minimumSplash = Duration(seconds: 2);

  testWidgets(
      'becomes ready once data is loaded and the minimum splash elapsed',
      (tester) async {
    final repository = FakeUserRepository(emitsOnListen: false);
    final session = AppSession(
      userRepository: repository,
      minimumSplashDuration: minimumSplash,
    );
    var notifications = 0;
    session.addListener(() => notifications++);

    await tester.pump(minimumSplash);
    expect(session.isReady, isFalse, reason: 'data not loaded yet');

    repository.emitStoredValues();
    await tester.pump();

    expect(session.isReady, isTrue);
    expect(notifications, 1);
    session.dispose();
  });

  testWidgets('waits for the minimum splash even when data loads instantly',
      (tester) async {
    final session = AppSession(
      userRepository: FakeUserRepository(),
      minimumSplashDuration: minimumSplash,
    );

    await tester.pump(minimumSplash - const Duration(milliseconds: 1));
    expect(session.isReady, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(session.isReady, isTrue);
    session.dispose();
  });

  testWidgets('reflects the stored user and settings', (tester) async {
    final session = AppSession(
      userRepository: FakeUserRepository(user: signedInUser),
      minimumSplashDuration: Duration.zero,
    );
    await tester.pump();

    expect(session.isSignedIn, isTrue);
    expect(session.hasPassedOnboarding, isTrue);
    session.dispose();
  });

  testWidgets(
      'still becomes ready, as a first-launch guest, when storage fails',
      (tester) async {
    final repository = FakeUserRepository(emitsOnListen: false);
    final session = AppSession(
      userRepository: repository,
      minimumSplashDuration: Duration.zero,
    );
    await tester.pump();

    repository.failToLoad();
    await tester.pump(const Duration(milliseconds: 1));

    expect(session.isReady, isTrue);
    expect(session.isSignedIn, isFalse);
    expect(session.hasPassedOnboarding, isFalse);
    session.dispose();
  });

  testWidgets('completeOnboarding flips the flag synchronously and stores it',
      (tester) async {
    final repository = FakeUserRepository(passedOnBoarding: false);
    final session = AppSession(
      userRepository: repository,
      minimumSplashDuration: Duration.zero,
    );
    await tester.pump();
    expect(session.hasPassedOnboarding, isFalse);

    session.completeOnboarding();
    expect(session.hasPassedOnboarding, isTrue);

    await tester.pump();
    expect(
      repository.upsertedSettings,
      [UserSettings(passedOnBoarding: true)],
    );
    session.dispose();
  });

  testWidgets('follows sign-in and sign-out without notifying', (tester) async {
    final repository = FakeUserRepository();
    final session = AppSession(
      userRepository: repository,
      minimumSplashDuration: Duration.zero,
    );
    await tester.pump();
    var notifications = 0;
    session.addListener(() => notifications++);

    repository.signIn('user@example.com', 'password');
    await tester.pump();

    expect(session.isSignedIn, isTrue);
    expect(notifications, 0);
    session.dispose();
  });
}
