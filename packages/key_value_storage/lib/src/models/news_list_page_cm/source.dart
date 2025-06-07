import 'package:hive/hive.dart';

part 'source.g.dart';

@HiveType(typeId: 4)
class SourceCM extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  SourceCM({
    this.id,
    this.name,
  });
}
