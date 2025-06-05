import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';

import 'package:monitoring/monitoring.dart';

import 'package:routemaster/routemaster.dart';

import 'package:user_repository/user_repository.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  required UserRepository userRepository,
  //TODOTip add the neassery Repository
}) {
  return {};
}

class _PathConstants {
  const _PathConstants._();
  static String get homePath => '/';
}
