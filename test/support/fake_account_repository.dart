import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/account_repository.dart';
import 'package:wasli_customer/features/account/domain/code_channel.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';
import 'package:wasli_customer/features/account/domain/customer_session.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

/// A code the fake server "sent": valid for ten minutes, a new one after one minute.
const demoSentCode = SentCode(
  identifier: 'sara@example.com',
  channel: CodeChannel.email,
  expiresIn: Duration(minutes: 10),
  resendAvailableIn: Duration(minutes: 1),
);

/// A customer for tests: invented values.
const demoCustomer = Customer(
  id: '3f2b8c1e-7a4d-4e6b-9c1a-5d2e8f0b1a11',
  fullName: 'Sara Demo',
  language: CustomerLanguage.english,
  email: 'sara@example.com',
  emailVerified: true,
  phone: null,
  phoneVerified: false,
);

/// A session for tests: an invented token and [demoCustomer].
const demoSession = CustomerSession(token: 'demo-token-not-a-real-token', customer: demoCustomer);

/// An [AccountRepository] for tests. Each call is recorded in [calls] (names only, never values that would be personal
/// data in a real app) and answers with what [onSignUp], [onVerify] and [onResend] do; every other call is not expected.
class FakeAccountRepository implements AccountRepository {
  /// Creates a repository that accepts every call with the demo answers.
  new({this.onSignUp, this.onVerify, this.onResend, this.onLogIn});

  /// What a sign-up does; the demo code by default.
  Future<SentCode> Function(AccountContact contact, CustomerLanguage language)? onSignUp;

  /// What a verify does; the demo session by default.
  Future<CustomerSession> Function(String identifier, String code)? onVerify;

  /// What a sign-in does; the demo session by default.
  Future<CustomerSession> Function(String identifier, String password)? onLogIn;

  /// What a resend does; the demo code by default.
  Future<SentCode> Function(String identifier)? onResend;

  /// The names of the calls made, in order.
  final List<String> calls = [];

  /// The contact of the last sign-up.
  AccountContact? lastContact;

  /// The language of the last sign-up.
  CustomerLanguage? lastLanguage;

  /// The identifier of the last sign-in.
  String? lastIdentifier;

  /// The code of the last verify.
  String? lastCode;

  @override
  Future<SentCode> signUp({
    required String fullName,
    required AccountContact contact,
    required String password,
    required CustomerLanguage language,
  }) async {
    calls.add('signUp');
    lastContact = contact;
    lastLanguage = language;
    return onSignUp == null ? demoSentCode : await onSignUp!(contact, language);
  }

  @override
  Future<CustomerSession> verify({required String identifier, required String code}) async {
    calls.add('verify');
    lastCode = code;
    return onVerify == null ? demoSession : await onVerify!(identifier, code);
  }

  @override
  Future<SentCode> resendCode({required String identifier}) async {
    calls.add('resendCode');
    return onResend == null ? demoSentCode : await onResend!(identifier);
  }

  @override
  Future<CustomerSession> logIn({required String identifier, required String password}) async {
    calls.add('logIn');
    lastIdentifier = identifier;
    return onLogIn == null ? demoSession : await onLogIn!(identifier, password);
  }

  @override
  Future<void> logOut() => throw UnimplementedError();

  @override
  Future<Customer> currentCustomer() => throw UnimplementedError();

  @override
  Future<SentCode> addContact(AccountContact contact) => throw UnimplementedError();

  @override
  Future<Customer> verifyContact({required String code}) => throw UnimplementedError();

  @override
  Future<Duration> requestPasswordReset({required String identifier}) => throw UnimplementedError();

  @override
  Future<void> resetPassword({required String identifier, required String code, required String newPassword}) =>
      throw UnimplementedError();
}
