import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

class _FailingTokenStore implements TokenStore {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String token) async => throw StateError('storage unavailable');

  @override
  Future<void> clear() async {}
}

void main() {
  late MemoryTokenStore store;
  late ProviderContainer container;

  ProviderContainer containerWith(TokenStore tokenStore) {
    final created = ProviderContainer(overrides: [tokenStoreProvider.overrideWithValue(tokenStore)]);
    addTearDown(created.dispose);
    return created;
  }

  setUp(() {
    store = MemoryTokenStore();
    container = containerWith(store);
  });

  test('starts signed out', () {
    expect(container.read(sessionProvider), isA<SignedOut>());
  });

  test('signing in keeps the token and moves to signed in', () async {
    await container.read(sessionProvider.notifier).signIn('token-1');

    expect(container.read(sessionProvider), isA<SignedIn>());
    expect(await store.read(), 'token-1');
  });

  test('a store that cannot save leaves the customer signed out', () async {
    final failing = containerWith(_FailingTokenStore());

    await expectLater(failing.read(sessionProvider.notifier).signIn('token-1'), throwsStateError);

    expect(failing.read(sessionProvider), isA<SignedOut>());
  });

  test('signing out forgets the token and moves to signed out', () async {
    await container.read(sessionProvider.notifier).signIn('token-1');
    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider), isA<SignedOut>());
    expect(await store.read(), isNull);
  });

  test('a 401 announced by the network layer signs the customer out', () async {
    await container.read(sessionProvider.notifier).signIn('token-1');
    expect(container.read(sessionProvider), isA<SignedIn>());

    container.read(sessionExpiredProvider.notifier).announce();

    expect(container.read(sessionProvider), isA<SignedOut>().having((state) => state.expired, 'expired', isTrue));
  });

  test('signing out or never signing in is not an expired session', () async {
    expect((container.read(sessionProvider) as SignedOut).expired, isFalse);

    await container.read(sessionProvider.notifier).signIn('token-1');
    await container.read(sessionProvider.notifier).signOut();

    expect((container.read(sessionProvider) as SignedOut).expired, isFalse);
  });

  test('signing in again after a 401 works', () async {
    await container.read(sessionProvider.notifier).signIn('token-1');
    container.read(sessionExpiredProvider.notifier).announce();
    await container.read(sessionProvider.notifier).signIn('token-2');

    expect(container.read(sessionProvider), isA<SignedIn>());
    expect(await store.read(), 'token-2');
  });
}
