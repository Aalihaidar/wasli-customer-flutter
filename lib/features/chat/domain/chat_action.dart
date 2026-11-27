/// What a button of the conversation does. The server offers these as quick replies and accepts them as they are; the
/// app never makes one up except the ones for its own buttons.
sealed class ChatAction {
  const new();
}

/// Which part of the review the customer wants to change.
enum ChatField {
  /// The ordered items.
  items,

  /// The car and the parking place.
  car,

  /// The note.
  note,
}

/// Confirms the order (at the summary, and finally at the review).
final class ConfirmAction extends ChatAction {
  /// Creates the action.
  const new();
}

/// Asks to change something.
final class EditAction extends ChatAction {
  /// Creates the action.
  const new();
}

/// Changes one part of the review.
final class EditFieldAction extends ChatAction {
  /// Creates the action for [field].
  const new(this.field);

  /// What to change.
  final ChatField field;
}

/// Answers a choice question of the server with the value of the chosen option.
final class ChooseAction extends ChatAction {
  /// Creates the action for [value].
  const new(this.value);

  /// The id of the chosen option.
  final String value;
}

/// Skips the optional note.
final class SkipNoteAction extends ChatAction {
  /// Creates the action.
  const new();
}

/// Starts the order again from the beginning (before it is placed).
final class RestartAction extends ChatAction {
  /// Creates the action.
  const new();
}
