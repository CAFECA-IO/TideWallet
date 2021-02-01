class Config {
  static final Config _instance = Config._internal();
  factory Config() => _instance;
  static const bool remoteLog = false;
  static const int logLevel = 0;
  static const String logServer = "https://log.mermer.cc/";
  Config._internal();
}