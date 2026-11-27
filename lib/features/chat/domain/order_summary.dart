/// One line of the order: what the customer asked for and what the server charges for it.
class SummaryLine {
  /// Creates a line.
  const new({
    required this.name,
    required this.optionNames,
    required this.quantity,
    required this.note,
    required this.lineTotalMinor,
  });

  /// The item's name, in the conversation's language.
  final String name;

  /// The names of the chosen options.
  final List<String> optionNames;

  /// How many.
  final int quantity;

  /// The customer's note for this line, or `null`.
  final String? note;

  /// What the line costs, in minor units (fils), computed by the server.
  final int lineTotalMinor;
}

/// The order as the server priced it. The app shows these numbers and never computes a price.
class OrderSummary {
  /// Creates a summary.
  const new({required this.lines, required this.subtotalMinor, required this.totalMinor, required this.currency});

  /// The lines, in the server's order.
  final List<SummaryLine> lines;

  /// The sum of the lines, in minor units.
  final int subtotalMinor;

  /// What the customer pays, in minor units, VAT included.
  final int totalMinor;

  /// The ISO currency code (`AED`).
  final String currency;
}
