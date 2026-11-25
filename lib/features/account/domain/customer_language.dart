/// The language of a customer's account: the one the codes and messages are written in.
///
/// Only the two languages of the product exist. An answer with another code reads as English, the language the app
/// starts in, so an account is never rejected for a language this version does not know.
enum CustomerLanguage {
  /// English (`en`).
  english('en'),

  /// Arabic (`ar`), written right to left.
  arabic('ar');

  new(this.code);

  /// The code the server uses.
  final String code;

  /// The language for [code], or [english] when it is not one of the product's.
  static CustomerLanguage fromCode(String code) => code == arabic.code ? arabic : english;
}
