import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

void main() {
  group('MemoryTokenStore', () {
    test('starts empty, keeps what is written and forgets on clear', () async {
      final store = MemoryTokenStore();

      expect(await store.read(), isNull);
      await store.write('tok-1');
      expect(await store.read(), 'tok-1');
      await store.write('tok-2');
      expect(await store.read(), 'tok-2');
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('can start with a token', () async {
      expect(await MemoryTokenStore('tok-1').read(), 'tok-1');
    });
  });
}
