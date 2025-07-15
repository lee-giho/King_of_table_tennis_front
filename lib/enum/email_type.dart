enum EmailType {
  register("register"),
  findId("find-id"),
  findPassword("find-password");

  final String value;
  const EmailType(this.value);

  static EmailType? from(String value) {
    return EmailType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError("Invalid EmailType: $value"),
    );
  }
}