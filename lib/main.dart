import 'dart:async';

import 'package:article_list/article_list.dart';
import 'package:component_library/component_library.dart';
import 'package:article/article.dart';

import 'package:flutter/material.dart';

import 'package:key_value_storage/key_value_storage.dart';

import 'package:news_api/news_api.dart';
import 'package:news_repository/news_repository.dart';

import 'package:routemaster/routemaster.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';

import 'l10n/app_localizations.dart';
import 'screen_view_observer.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _keyValueStorage = KeyValueStorage();

  late final NewsApi _newsApi = NewsApi();

  late final NewsRepository _newsRepository = NewsRepository(
    keyValueStorage: _keyValueStorage,
    remoteApi: _newsApi,
  );

  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
      observers: [ScreenViewObserver()],
      routesBuilder: (context) {
        return RouteMap(
          routes: buildRoutingTable(
            routerDelegate: _routerDelegate,
            newsRepository: _newsRepository,
          ),
        );
      });

  late StreamSubscription _incomingDynamicLinksSubscription;
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WonderTheme(
      lightTheme: _lightTheme,
      darkTheme: _darkTheme,
      child: MaterialApp.router(
        title: 'RWF Architecture',
        theme: _lightTheme.materialThemeData,
        darkTheme: _darkTheme.materialThemeData,
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ar', 'SA'),
        ],
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          AppLocalizations.delegate,
          ComponentLibraryLocalizations.delegate,
          ArticleListLocalizations.delegate,
          ArticleLocalizations.delegate,
        ],
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: _routerDelegate,
      ),
    );
  }
}
