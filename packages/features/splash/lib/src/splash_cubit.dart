import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'splash_state.dart';

typedef AppVersionLoader = Future<String> Function();

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    @visibleForTesting AppVersionLoader? versionLoader,
  })  : _loadVersion = versionLoader ?? _loadPlatformVersion,
        super(const SplashState()) {
    _init();
  }

  final AppVersionLoader _loadVersion;

  Future<void> _init() async {
    try {
      final version = await _loadVersion();
      if (isClosed) {
        return;
      }
      emit(SplashState(version: version));
    } catch (_) {
      // The version label is decorative; the splash works without it.
    }
  }

  static Future<String> _loadPlatformVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
