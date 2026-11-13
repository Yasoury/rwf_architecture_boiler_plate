part of 'splash_cubit.dart';

class SplashState extends Equatable {
  const SplashState({
    this.version,
  });

  /// The app version, or null until it has been read.
  final String? version;

  @override
  List<Object?> get props => [
        version,
      ];
}
