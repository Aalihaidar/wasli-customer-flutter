import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';
import 'package:wasli_customer/features/account/domain/customer_session.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

/// Everything the app does with a customer's account on the server.
///
/// Every method throws a `Failure` when the call does not succeed (`core/error`); the screens map the failure to their
/// own text. None of them stores a token: the session code keeps the token of a [CustomerSession].
abstract interface class AccountRepository {
  /// Creates an account with [contact] and sends it a code. `ConflictFailure(account_exists)` when the contact is taken.
  Future<SentCode> signUp({
    required String fullName,
    required AccountContact contact,
    required String password,
    required CustomerLanguage language,
  });

  /// Confirms the sign-up code sent to [identifier] and signs in.
  Future<CustomerSession> verify({required String identifier, required String code});

  /// Sends a new code to [identifier]. The answer is the same whether or not the account exists.
  Future<SentCode> resendCode({required String identifier});

  /// Signs in with the email or phone [identifier] and the password.
  Future<CustomerSession> logIn({required String identifier, required String password});

  /// Revokes this device's token on the server.
  Future<void> logOut();

  /// The signed-in customer's profile.
  Future<Customer> currentCustomer();

  /// Starts adding the missing contact: sends [contact] a code. It is saved only after [verifyContact].
  Future<SentCode> addContact(AccountContact contact);

  /// Confirms the code sent for the contact being added and returns the updated profile.
  Future<Customer> verifyContact({required String code});

  /// Sends a password-reset code to [identifier] when such an account exists; the answer is the same either way.
  /// Returns how long the code is valid.
  Future<Duration> requestPasswordReset({required String identifier});

  /// Sets [newPassword] with the code from the reset message. The server then revokes every token of the customer.
  Future<void> resetPassword({required String identifier, required String code, required String newPassword});
}
