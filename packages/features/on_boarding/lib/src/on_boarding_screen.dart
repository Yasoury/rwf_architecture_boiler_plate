import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:on_boarding/src/on_boarding_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({
    super.key,
    this.navigateToHome,
  });
  final VoidCallback? navigateToHome;

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final bloc = OnboardingBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bloc.initState(onBoardingViewed: false);
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = OnBoardingLocalizations.of(context);
    final theme = WonderTheme.of(context);

    final size = MediaQuery.of(context).size;
    return StyledStatusBar.dark(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                onPageChanged: (index) {
                  bloc.onPageUpdate(index: index);
                },
                controller: bloc.pageController,
                children: [
                  onBording1(l10n, context, theme, size),
                  onBording2(l10n, context, theme, size),
                ],
              ),
              Positioned(
                  left: size.width * .425,
                  bottom: Spacing.medium,
                  child: SmoothPageIndicator(
                    controller: bloc.pageController,
                    count: 2,
                    effect: ExpandingDotsEffect(
                      activeDotColor: theme.accentColor,
                      dotHeight: size.height * .01,
                    ),
                    onDotClicked: (index) {
                      bloc.onDotSelected(index: index);
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget onBording1(
    OnBoardingLocalizations l10n,
    BuildContext context,
    WonderThemeData theme,
    Size size,
  ) {
    return Stack(
      children: [
        Center(
          heightFactor: 1.1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: SvgPicture.asset(
              AssetsConst.onboardingSvgImage2,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: size.height * .35,
            width: size.width,
            decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: .1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.onBoardingTitle,
                  style: const TextStyle(
                    fontSize: FontSize.mediumLarge * 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: Text(
                    l10n.onBoardingTitleSubTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: FontSize.mediumLarge * .85,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                SizedBox(
                  width: size.width * .66,
                  child: ExpandedElevatedButton(
                    label: l10n.next,
                    color: theme.accentColor,
                    onTap: () {
                      bloc.onDotSelected(index: 1);
                    },
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              InkWell(
                onTap: widget.navigateToHome,
                child: Text(
                  l10n.skip,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget onBording2(
    OnBoardingLocalizations l10n,
    BuildContext context,
    WonderThemeData theme,
    Size size,
  ) {
    return Stack(
      children: [
        Center(
          heightFactor: 1.1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: SvgPicture.asset(
              AssetsConst.onboardingSvgImage1,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: size.height * .35,
            width: size.width,
            decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: .1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(48),
                  topRight: Radius.circular(48),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.onBoardingTitle,
                  style: const TextStyle(
                    fontSize: FontSize.mediumLarge * 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: Text(
                    l10n.onBoardingTitleSubTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: FontSize.mediumLarge * .85,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                SizedBox(
                  width: size.width * .66,
                  child: ExpandedElevatedButton(
                    label: l10n.startNow,
                    color: theme.accentColor,
                    onTap: widget.navigateToHome,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
