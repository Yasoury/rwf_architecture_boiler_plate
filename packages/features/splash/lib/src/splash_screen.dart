import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splash/src/splash_cubit.dart';
import 'package:rive/rive.dart' as rive;
import 'package:user_repository/user_repository.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.navigateToOnBarding,
    required this.navigateAuthIntro,
    required this.navigateToHomeScreen,
    required this.userRepository,
  });

  final UserRepository userRepository;
  final VoidCallback? navigateToOnBarding;
  final VoidCallback? navigateAuthIntro;
  final VoidCallback? navigateToHomeScreen;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider<SplashCubit>(
      create: (_) => SplashCubit(
        userRepository: userRepository,
        screenSize: size,
      ),
      child: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            switch (state.navigationStatus) {
              case NavigationStatus.navigateToHomeScreen:
                navigateToHomeScreen?.call();
                break;
              case NavigationStatus.navigateAuthIntro:
                navigateAuthIntro?.call();
                break;
              case NavigationStatus.navigateToOnBarding:
                navigateToOnBarding?.call();
                break;
              default:
                break;
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    decoration: BoxDecoration(
                      color: WonderTheme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(), // Placeholder for spacing
                        BlocBuilder<SplashCubit, SplashState>(
                          builder: (context, state) {
                            double logoSize = state is SplashLoaded
                                ? state.size ?? 0
                                : 0; // Default logo size

                            return Expanded(
                              child: Center(
                                child: AnimatedContainer(
                                  width: logoSize,
                                  height: logoSize,
                                  padding: const EdgeInsets.all(20),
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.fastOutSlowIn,
                                  child: const rive.RiveAnimation.asset(
                                    AssetsConst.loadingAnimation,
                                    animations: ["v4"], //v1,v2,v3,v4
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.5,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child:
                                        BlocBuilder<SplashCubit, SplashState>(
                                      builder: (context, state) {
                                        String version = state is SplashLoaded
                                            ? "V. ${state.version ?? "1.0"}"
                                            : "V. 1.0"; // Default version

                                        return Text(
                                          "Powered By: RWF : $version",
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .03,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
