import 'package:dio/dio.dart';
import 'package:wasli_customer/api/api.dart' as api;
import 'package:wasli_customer/core/network/run_api.dart';
import 'package:wasli_customer/features/account/data/account_mapper.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/account_repository.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';
import 'package:wasli_customer/features/account/domain/customer_session.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

/// Runs the account calls through the generated `CustomersClient`.
///
/// Each call goes through `runApi`, so a failure reaches the caller as a `Failure`. The customer token is added by the
/// network layer to the calls that need it (`logout`, `me`, the contact calls) and to no other.
class AccountRepositoryImpl implements AccountRepository {
  /// Creates the repository over the generated client.
  const new(this._client);

  /// Creates the repository over the app's HTTP client, building the generated client here, because only `data/`
  /// imports `lib/api`.
  factory fromDio(Dio dio) => AccountRepositoryImpl(api.CustomersClient(dio));

  final api.CustomersClient _client;

  @override
  Future<SentCode> signUp({
    required String fullName,
    required AccountContact contact,
    required String password,
    required CustomerLanguage language,
  }) async {
    final dto = await runApi(
      () => _client.customersSignup(
        body: api.SignupRequest$Request(
          fullName: fullName,
          email: switch (contact) {
            EmailContact(:final value) => value,
            PhoneContact() => null,
          },
          phone: switch (contact) {
            PhoneContact(:final value) => value,
            EmailContact() => null,
          },
          password: password,
          locale: api.LocaleEnum.fromJson(language.code),
        ),
      ),
    );
    return sentCodeFromDto(dto);
  }

  @override
  Future<CustomerSession> verify({required String identifier, required String code}) async {
    final dto = await runApi(
      () => _client.customersVerify(
        body: api.VerifyRequest(identifier: identifier, code: code),
      ),
    );
    return customerSessionFromDto(dto);
  }

  @override
  Future<SentCode> resendCode({required String identifier}) async {
    final dto = await runApi(() => _client.customersResendCode(body: api.ResendRequest(identifier: identifier)));
    return sentCodeFromDto(dto);
  }

  @override
  Future<CustomerSession> logIn({required String identifier, required String password}) async {
    final dto = await runApi(
      () => _client.customersLogin(
        body: api.LoginRequest$Request(identifier: identifier, password: password),
      ),
    );
    return customerSessionFromDto(dto);
  }

  @override
  Future<void> logOut() => runApi(_client.customersLogout);

  @override
  Future<Customer> currentCustomer() async => customerFromDto(await runApi(_client.customersMe));

  @override
  Future<SentCode> addContact(AccountContact contact) async {
    final dto = await runApi(
      () => _client.customersContactAdd(
        body: api.ContactRequest(
          email: switch (contact) {
            EmailContact(:final value) => value,
            PhoneContact() => null,
          },
          phone: switch (contact) {
            PhoneContact(:final value) => value,
            EmailContact() => null,
          },
        ),
      ),
    );
    return sentCodeFromDto(dto);
  }

  @override
  Future<Customer> verifyContact({required String code}) async {
    final dto = await runApi(() => _client.customersContactVerify(body: api.ContactVerifyRequest(code: code)));
    return customerFromDto(dto);
  }

  @override
  Future<Duration> requestPasswordReset({required String identifier}) async {
    final dto = await runApi(
      () => _client.customersPasswordReset(body: api.PasswordResetRequest(identifier: identifier)),
    );
    return Duration(seconds: dto.codeExpiresInSeconds);
  }

  @override
  Future<void> resetPassword({required String identifier, required String code, required String newPassword}) {
    return runApi(
      () => _client.customersPasswordResetConfirm(
        body: api.PasswordResetConfirmRequest$Request(identifier: identifier, code: code, newPassword: newPassword),
      ),
    );
  }
}
