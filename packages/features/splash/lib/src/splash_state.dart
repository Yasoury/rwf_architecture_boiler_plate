part of 'splash_cubit.dart';

class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInProgress extends SplashState {}

class SplashLoaded extends SplashState {
  final double? size;
  final String? version;
  final NavigationStatus? navigationStatus;

  SplashLoaded({
    this.size,
    this.version,
    this.navigationStatus,
  });

  SplashLoaded copyWith({
    double? size,
    String? version,
    NavigationStatus? navigationStatus,
  }) {
    return SplashLoaded(
      size: size ?? this.size,
      version: version ?? this.version,
      navigationStatus: navigationStatus ?? this.navigationStatus,
    );
  }

  @override
  List<Object?> get props => [
        size,
        version,
        navigationStatus,
      ];
}

enum NavigationStatus {
  idle,
  navigateToHomeScreen,
  navigateAuthIntro,
  navigateToOnBarding,
}
