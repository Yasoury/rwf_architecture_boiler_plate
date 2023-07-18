import 'package:key_value_storage/key_value_storage.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

/// Wraps [Hive] so that we can register all adapters and manage all keys in a
/// single place.
///
/// To use this class, simply unwrap one of its exposed boxes, like
/// [darkModePreferenceBox], and execute operations in it, for example:
///
/// ```
/// (await darkModePreferenceBox).clear();
/// ```
///
/// Storing non-primitive types in Hive requires us to use incremental [typeId]s.
/// Having all these models and boxes' keys in a single package allows us to
/// avoid conflicts.
class KeyValueStorage {
  //TODO add the keys for new boxes /cart,favorate....
  static const _darkModePreferenceBoxKey = 'dark-mode-preference';

  KeyValueStorage({
    @visibleForTesting HiveInterface? hive,
  }) : _hive = hive ?? Hive {
    try {
      _hive.registerAdapter(DarkModePreferenceCMAdapter());
    } catch (_) {
      throw Exception(
          'You shouldn\'t have more than one [KeyValueStorage] instance in your '
          'project');
    }
  }

  final HiveInterface _hive;

  Future<Box<DarkModePreferenceCM>> get darkModePreferenceBox =>
      _openHiveBox<DarkModePreferenceCM>(
        _darkModePreferenceBoxKey,
        isTemporary: false,
      );

  Future<Box<T>> _openHiveBox<T>(
    String boxKey, {
    required bool isTemporary,
  }) async {
    if (_hive.isBoxOpen(boxKey)) {
      return _hive.box(boxKey);
    } else {
      final directory = await (isTemporary
          ? getTemporaryDirectory()
          : getApplicationDocumentsDirectory());
      return _hive.openBox<T>(
        boxKey,
        path: directory.path,
      );
    }
  }
}
