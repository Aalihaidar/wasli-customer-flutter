import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/features/start/domain/restaurant_slug.dart';

void main() {
  group('isValidRestaurantSlug', () {
    test('accepts letters, digits, hyphens and underscores', () {
      for (final slug in ['demo-cafe', 'Demo_Cafe2', 'a', '7-eleven', 'x' * maxRestaurantSlugLength]) {
        expect(isValidRestaurantSlug(slug), isTrue, reason: slug);
      }
    });

    test('refuses anything else, so it never reaches a path', () {
      for (final slug in [
        '',
        ' ',
        'demo cafe',
        'demo/cafe',
        '..',
        '../x',
        '-demo',
        '_demo',
        'demo.cafe',
        'demo?x=1',
        'demo%2Fcafe',
        'مقهى',
        '<script>',
        'x' * (maxRestaurantSlugLength + 1),
        'demo\n',
      ]) {
        expect(isValidRestaurantSlug(slug), isFalse, reason: slug);
      }
    });

    test('refuses the slug the API reserves', () {
      expect(isValidRestaurantSlug('nearby'), isFalse);
      expect(isValidRestaurantSlug('nearby-cafe'), isTrue);
    });
  });
}
