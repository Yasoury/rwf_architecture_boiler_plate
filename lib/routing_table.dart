import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';

import 'package:monitoring/monitoring.dart';
import 'package:news_repository/news_repository.dart';

import 'package:routemaster/routemaster.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  required NewsRepository newsRepository,
  //TODOTip add the neassery Repository
}) {
  return {};
}

class _PathConstants {
  const _PathConstants._();
  static String get homePath => '/news';
  static String get idPathParameter => 'id';

  static String articleDetailsPath({
    int? articleId,
  }) =>
      '$homePath/${articleId ?? ':$idPathParameter'}';
}
