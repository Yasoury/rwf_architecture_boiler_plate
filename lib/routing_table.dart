import 'package:monitoring/monitoring.dart';
import 'package:routemaster/routemaster.dart';
import 'tab_container_screen.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  //TODO add the neassery Repository
}) {
  return {
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [
            _PathConstants.quoteListPath,
            _PathConstants.profileMenuPath,
          ],
        ),
  };
}

class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';

  static String get quoteListPath => '${tabContainerPath}home_scren';

  static String get profileMenuPath => '${tabContainerPath}user';
}
