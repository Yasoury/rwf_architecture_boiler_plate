class SourceRM {
  dynamic id;
  String? name;

  SourceRM({this.id, this.name});

  factory SourceRM.fromJson(Map<String, dynamic> json) => SourceRM(
        id: json['id'] as dynamic,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
