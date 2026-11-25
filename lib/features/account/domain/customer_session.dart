import 'package:wasli_customer/features/account/domain/customer.dart';

/// What the server gives back when a customer proves who they are (`verify` and `login`): the token of this device and
/// the profile. The only two answers that carry a token.
class CustomerSession {
  /// Creates a session answer.
  const new({required this.token, required this.customer});

  /// The token of this device. Goes to the `TokenStore` and nowhere else; never logged.
  final String token;

  /// The customer it belongs to.
  final Customer customer;
}
