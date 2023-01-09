class Credentials {
  final String host;
  final String username;
  final String password;

  Credentials(this.host, this.username, this.password);

  Map<String, String> toCodec() => {
        'host': host,
        'username': username,
        'password': password,
      };
}
