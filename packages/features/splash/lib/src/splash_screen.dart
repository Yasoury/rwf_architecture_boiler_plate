import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart' as rive;
import 'package:splash/src/l10n/splash_localizations.dart';
import 'package:splash/src/splash_cubit.dart';

/// Shown while the app starts up. The main app's router decides when and where
/// to move on, so this screen has no navigation callbacks.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => SplashCubit(),
      child: const SplashView(),
    );
  }
}

@visibleForTesting
class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: WonderTheme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _AnimatedLogo(
                  size: size.width / 1.5,
                ),
              ),
            ),
            SizedBox(
              width: size.width / 2.5,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: BlocBuilder<SplashCubit, SplashState>(
                  builder: (context, state) {
                    final version = state.version;
                    return Text(
                      version == null
                          ? ''
                          : SplashLocalizations.of(context).poweredBy(version),
                      style: TextStyle(
                        fontSize: size.width * .03,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: size.height * .12,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: size),
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
      builder: (context, animatedSize, child) {
        return SizedBox.square(
          dimension: animatedSize,
          child: child,
        );
      },
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: rive.RiveAnimation.asset(
          AssetsConst.loadingAnimation,
          animations: ["v4"], //v1,v2,v3,v4
        ),
      ),
    );
  }
}
