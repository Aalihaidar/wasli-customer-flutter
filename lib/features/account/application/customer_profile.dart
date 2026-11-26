import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';

/// The signed-in customer's profile, read from the server when a screen first asks for it.
///
/// It is dropped when no screen shows it, so the next customer on the same device never sees the previous profile.
/// A failed read is not retried by itself (the screen has a "Try again" button), and a `401` ends the session in the
/// network layer. Invalidate it after the profile changes.
final FutureProvider<Customer> customerProfileProvider = FutureProvider.autoDispose<Customer>(
  (ref) => ref.watch(accountRepositoryProvider).currentCustomer(),
  retry: (retryCount, error) => null,
);
