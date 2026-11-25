import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/features/account/data/account_repository_impl.dart';
import 'package:wasli_customer/features/account/domain/account_repository.dart';

/// The customer's account on the server. Tests replace it with a fake.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl.fromDio(ref.watch(dioProvider)),
);
