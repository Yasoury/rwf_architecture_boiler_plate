import 'dart:async';

import 'package:flutter/material.dart';

class OnboardingBloc {
  final PageController _pageController = PageController();

  get pageController => _pageController;
  final StreamController<int> _selectedIndexController = StreamController()
    ..add(0);

  Stream<int> get selectedIndexStream => _selectedIndexController.stream;

  final StreamController<bool> _isOnBoardingViwedController = StreamController()
    ..add(false);

  Stream<bool> get isLoggedInStream => _isOnBoardingViwedController.stream;
  void setSelectedBottomNavBar({required int index}) {
    _selectedIndexController.sink.add(index);
  }

  initState({required bool onBoardingViewed}) {
    _isOnBoardingViwedController.sink.add(onBoardingViewed);
  }

  dispose() {
    _selectedIndexController.close();
    _isOnBoardingViwedController.close();
    _pageController.dispose();
  }

  onDotSelected({required int index}) {
    _selectedIndexController.sink.add(index);
    _pageController.animateToPage(index,
        duration: const Duration(microseconds: 500), curve: Curves.ease);
  }

  onPageUpdate({required int index}) {
    _selectedIndexController.sink.add(index);
  }
}
