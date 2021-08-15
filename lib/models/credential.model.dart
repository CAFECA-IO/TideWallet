class Credential {
  final String key;
  final String password;
  final String extend;

  Credential({required this.key, required this.password, required this.extend});

  Credential copyWith({String? key, String? password, String? extend}) {
    return Credential(
      key: key ?? this.key,
      password: password ?? this.password,
      extend: extend ?? this.extend,
    );
  }
}
