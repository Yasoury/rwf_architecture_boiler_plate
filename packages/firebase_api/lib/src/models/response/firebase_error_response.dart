class FirebaseErrorResponse {
  Error? error;

  FirebaseErrorResponse({this.error});

  factory FirebaseErrorResponse.fromJson(Map<String, dynamic> json) {
    return FirebaseErrorResponse(
      error: json['error'] == null
          ? null
          : Error.fromJson(json['error'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'error': error?.toJson(),
      };
}

class Error {
  List<Error>? errors;
  int? code;
  String? message;

  Error({this.errors, this.code, this.message});

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        errors: (json['errors'] as List<dynamic>?)
            ?.map((e) => Error.fromJson(e as Map<String, dynamic>))
            .toList(),
        code: json['code'] as int?,
        message: json['message'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'errors': errors?.map((e) => e.toJson()).toList(),
        'code': code,
        'message': message,
      };
}
