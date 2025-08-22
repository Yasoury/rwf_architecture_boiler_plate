import 'dart:async';

import 'package:flutter/material.dart';

class OnboardingBloc {
  final PageController _pageController = PageController();

  PageController get pageController => _pageController;
  final StreamController<int> _selectedIndexController = StreamController()
    ..add(0);

  Stream<int> get selectedIndexStream => _selectedIndexController.stream;

  final StreamController<bool> _isOnBoardingViwedController = StreamController()
    ..add(false);

  Stream<bool> get isLoggedInStream => _isOnBoardingViwedController.stream;
  void setSelectedBottomNavBar({required int index}) {
    _selectedIndexController.sink.add(index);
  }

  void initState({required bool onBoardingViewed}) {
    _isOnBoardingViwedController.sink.add(onBoardingViewed);
  }

  void dispose() {
    _selectedIndexController.close();
    _isOnBoardingViwedController.close();
    _pageController.dispose();
  }

  void onDotSelected({required int index}) {
    _selectedIndexController.sink.add(index);
    _pageController.animateToPage(index,
        duration: const Duration(microseconds: 500), curve: Curves.ease);
  }

  void onPageUpdate({required int index}) {
    _selectedIndexController.sink.add(index);
  }
}
