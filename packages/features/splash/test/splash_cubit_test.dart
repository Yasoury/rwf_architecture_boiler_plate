import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:splash/src/splash_cubit.dart';

void main() {
  group('SplashCubit', () {
    test('starts without a version', () {
      final cubit =
          SplashCubit(versionLoader: () => Completer<String>().future);
      addTearDown(cubit.close);

      expect(cubit.state, const SplashState());
    });

    test('emits the app version once it is loaded', () async {
      final cubit = SplashCubit(versionLoader: () async => '1.2.3');
      addTearDown(cubit.close);

      await expectLater(
        cubit.stream,
        emits(const SplashState(version: '1.2.3')),
      );
    });

    test('keeps the initial state when the version cannot be read', () async {
      final cubit = SplashCubit(
        versionLoader: () async => throw Exception('no platform'),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state, const SplashState());
    });

    test('does not emit when closed before the version loads', () async {
      final version = Completer<String>();
      final cubit = SplashCubit(versionLoader: () => version.future);

      await cubit.close();
      version.complete('1.2.3');
      await pumpEventQueue();

      expect(cubit.state, const SplashState());
    });
  });
}
