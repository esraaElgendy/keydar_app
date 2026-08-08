class AccountType {
  static const String owner = 'owner';
  static const String searcher = 'searcher';

  static String _current = searcher;

  static String get current => _current;
  static void set(String type) => _current = type;
}
