import 'package:flutter_test/flutter_test.dart';
import 'package:rwf_architecture_boiler_plate/app_redirect.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';

void main() {
  String? redirect(
    String location, {
    bool isReady = true,
    bool isSignedIn = false,
    bool hasPassedOnboarding = true,
  }) {
    return appRedirect(
      location: Uri.parse(location),
      isReady: isReady,
      isSignedIn: isSignedIn,
      hasPassedOnboarding: hasPassedOnboarding,
    );
  }

  group('while starting up', () {
    test('stays on the splash', () {
      expect(redirect(AppRoutes.splash, isReady: false), isNull);
    });

    test('parks any other location behind the splash', () {
      expect(
        redirect(AppRoutes.updateProfile, isReady: false),
        '/?from=%2Fupdate-profile',
      );
    });
  });

  group('leaving the splash', () {
    test('a first launch goes to the onboarding', () {
      expect(
        redirect(AppRoutes.splash, hasPassedOnboarding: false),
        AppRoutes.onboarding,
      );
    });

    test('an onboarded guest goes home', () {
      expect(redirect(AppRoutes.splash), AppRoutes.homePath);
    });

    test('a signed-in user goes home', () {
      expect(redirect(AppRoutes.splash, isSignedIn: true), AppRoutes.homePath);
    });

    test('chains through the gates the parked location still needs', () {
      expect(
        redirect('/?from=%2Fupdate-profile'),
        '/sign-in?from=%2Fupdate-profile',
      );
      expect(
        redirect('/?from=%2Fapp%2Fprofile', hasPassedOnboarding: false),
        '/onboarding?from=%2Fapp%2Fprofile',
      );
    });

    test('resumes the parked location', () {
      expect(
        redirect('/?from=%2Fapp%2Fprofile'),
        AppRoutes.profileMenuPath,
      );
    });

    test('ignores a parked location that is not an in-app path', () {
      expect(redirect('/?from=https%3A%2F%2Fevil.example'), AppRoutes.homePath);
      expect(redirect('/?from=%2F%2Fevil.example'), AppRoutes.homePath);
      expect(redirect('/?from=%2F'), AppRoutes.homePath);
    });
  });

  group('onboarding gate', () {
    test('keeps the requested location for after the onboarding', () {
      expect(
        redirect(AppRoutes.profileMenuPath, hasPassedOnboarding: false),
        '/onboarding?from=%2Fapp%2Fprofile',
      );
    });

    test('lets the onboarding itself through', () {
      expect(
        redirect(AppRoutes.onboarding, hasPassedOnboarding: false),
        isNull,
      );
    });

    test('can be revisited after it was passed', () {
      expect(redirect(AppRoutes.onboarding), isNull);
    });
  });

  group('sign-in gate', () {
    test('guests can use the tabs and the auth screens', () {
      for (final location in [
        AppRoutes.homePath,
        AppRoutes.profileMenuPath,
        AppRoutes.userPreferencesPath,
        AppRoutes.signIn,
        AppRoutes.signUp,
      ]) {
        expect(redirect(location), isNull, reason: location);
      }
    });

    test('guests are sent to sign in before updating a profile', () {
      expect(
        redirect(AppRoutes.updateProfile),
        '/sign-in?from=%2Fupdate-profile',
      );
    });

    test('signed-in users can update their profile', () {
      expect(redirect(AppRoutes.updateProfile, isSignedIn: true), isNull);
    });
  });

  test('continueLocationOf reads the parked location', () {
    expect(
      continueLocationOf(Uri.parse('/sign-in?from=%2Fupdate-profile')),
      AppRoutes.updateProfile,
    );
    expect(continueLocationOf(Uri.parse('/sign-in')), isNull);
  });
}
