class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);

  Map<String, String> toCodec() => {
        "username": username,
        "password": password,
      };
}
