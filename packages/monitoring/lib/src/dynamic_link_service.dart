import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';

export 'package:firebase_dynamic_links/firebase_dynamic_links.dart'
    show SocialMetaTagParameters;

typedef OnNewDynamicLinkPath = void Function(String newDynamicLinkPath);

/// Wrapper around [FirebaseDynamicLinks].
class DynamicLinkService {
  //TODOTip define your deeplinking url
  static const _domainUriPrefix = "" /* 'https://rfwBoilerPlate1.page.link' */;
  //TODOTip define your bundleIDs

  static const _iOSBundleId = "" /* 'com.example.rfwBoilerPlate' */;
  static const _androidPackageName = "" /* 'com.example.rfwBoilerPlate' */;

  DynamicLinkService({
    @visibleForTesting FirebaseDynamicLinks? dynamicLinks,
  }) : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  final FirebaseDynamicLinks _dynamicLinks;

  Future<String> generateDynamicLinkUrl({
    required String path,
    SocialMetaTagParameters? socialMetaTagParameters,
  }) async {
    final parameters = DynamicLinkParameters(
      uriPrefix: _domainUriPrefix,
      link: Uri.parse(
        '$_domainUriPrefix$path',
      ),
      androidParameters: const AndroidParameters(
        packageName: _androidPackageName,
      ),
      iosParameters: const IOSParameters(
        bundleId: _iOSBundleId,
      ),
      socialMetaTagParameters: socialMetaTagParameters,
    );

    final shortLink = await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  Future<String?> getInitialDynamicLinkPath() async {
    final data = await _dynamicLinks.getInitialLink();
    final link = data?.link;
    return link?.path;
  }

  Stream<String> onNewDynamicLinkPath() {
    return _dynamicLinks.onLink.map(
      (PendingDynamicLinkData data) {
        final link = data.link;
        final path = link.path;
        return path;
      },
    );
  }
}
