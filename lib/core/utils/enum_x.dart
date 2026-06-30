/// Safely resolves an enum value from its stored [name], falling back when the
/// text is missing or unrecognised (e.g. an older DB row).
T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  return values.firstWhere((e) => e.name == name, orElse: () => fallback);
}
