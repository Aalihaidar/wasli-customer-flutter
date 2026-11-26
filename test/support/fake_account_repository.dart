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

/// A customer who signed up with a phone and has no email yet.
const demoPhoneCustomer = Customer(
  id: '3f2b8c1e-7a4d-4e6b-9c1a-5d2e8f0b1a12',
  fullName: 'Omar Demo',
  language: CustomerLanguage.arabic,
  email: null,
  emailVerified: false,
  phone: '+971500000000',
  phoneVerified: true,
);

/// [demoCustomer] after the phone `+971500000000` was added and confirmed.
const demoCustomerWithPhone = Customer(
  id: '3f2b8c1e-7a4d-4e6b-9c1a-5d2e8f0b1a11',
  fullName: 'Sara Demo',
  language: CustomerLanguage.english,
  email: 'sara@example.com',
  emailVerified: true,
  phone: '+971500000000',
  phoneVerified: true,
);

/// An [AccountRepository] for tests. Each call is recorded in [calls] (names only, never values that would be personal
/// data in a real app) and answers with what the `on...` callbacks do (the demo answers when one is not set); the
/// password-reset calls are not expected.
class FakeAccountRepository implements AccountRepository {
  /// Creates a repository that accepts every call with the demo answers.
  new({
    this.onSignUp,
    this.onVerify,
    this.onResend,
    this.onLogIn,
    this.onLogOut,
    this.onCurrentCustomer,
    this.onAddContact,
    this.onVerifyContact,
  });

  /// What a sign-out does; nothing by default.
  Future<void> Function()? onLogOut;

  /// What reading the profile does; [demoCustomer] by default.
  Future<Customer> Function()? onCurrentCustomer;

  /// What adding a contact does; the demo code by default.
  Future<SentCode> Function(AccountContact contact)? onAddContact;

  /// What confirming a contact does; [demoCustomerWithPhone] by default.
  Future<Customer> Function(String code)? onVerifyContact;

  /// The contact of the last add-a-contact call.
  AccountContact? lastAddedContact;

  /// The code of the last confirm-a-contact call.
  String? lastContactCode;

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
  Future<void> logOut() async {
    calls.add('logOut');
    await onLogOut?.call();
  }

  @override
  Future<Customer> currentCustomer() async {
    calls.add('currentCustomer');
    return onCurrentCustomer == null ? demoCustomer : await onCurrentCustomer!();
  }

  @override
  Future<SentCode> addContact(AccountContact contact) async {
    calls.add('addContact');
    lastAddedContact = contact;
    return onAddContact == null ? demoSentCode : await onAddContact!(contact);
  }

  @override
  Future<Customer> verifyContact({required String code}) async {
    calls.add('verifyContact');
    lastContactCode = code;
    return onVerifyContact == null ? demoCustomerWithPhone : await onVerifyContact!(code);
  }

  @override
  Future<Duration> requestPasswordReset({required String identifier}) => throw UnimplementedError();

  @override
  Future<void> resetPassword({required String identifier, required String code, required String newPassword}) =>
      throw UnimplementedError();
}
