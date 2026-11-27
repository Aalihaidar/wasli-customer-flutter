import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/polling/poller.dart';

void main() {
  const interval = Duration(seconds: 3);

  testWidgets('ticks every interval, one at a time, after the first pause', (tester) async {
    var ticks = 0;
    final poller = Poller(interval: () => interval, onTick: () async => ticks++)..start();

    await tester.pump(const Duration(seconds: 2));
    expect(ticks, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(ticks, 1);
    await tester.pump(const Duration(seconds: 9));
    expect(ticks, 4);
    poller.stop();
  });

  testWidgets('can tick at once', (tester) async {
    var ticks = 0;
    final poller = Poller(interval: () => interval, onTick: () async => ticks++)..start(immediately: true);

    await tester.pump();
    await tester.pump(Duration.zero);
    expect(ticks, 1);
    poller.stop();
  });

  testWidgets('stops when asked, and starts again', (tester) async {
    var ticks = 0;
    final poller = Poller(interval: () => interval, onTick: () async => ticks++)..start();
    await tester.pump(const Duration(seconds: 3));
    poller.stop();
    await tester.pump(const Duration(seconds: 30));

    expect(ticks, 1);
    expect(poller.isRunning, isFalse);

    poller.start();
    await tester.pump(const Duration(seconds: 3));
    expect(ticks, 2);
    poller.stop();
  });

  testWidgets('waits for a tick that is still running before the next pause', (tester) async {
    var ticks = 0;
    final poller = Poller(
      interval: () => interval,
      onTick: () async {
        ticks++;
        await Future<void>.delayed(const Duration(seconds: 10));
      },
    )..start();

    await tester.pump(const Duration(seconds: 12));
    expect(ticks, 1);
    await tester.pump(const Duration(seconds: 4));
    expect(ticks, 2);
    poller.stop();
    await tester.pump(const Duration(seconds: 11)); // the second tick's own wait ends
  });

  testWidgets('backs off after failures and returns to the normal pause after one that works', (tester) async {
    var calls = 0;
    var failing = true;
    final poller = Poller(
      interval: () => interval,
      onTick: () async {
        calls++;
        if (failing) {
          throw const NetworkFailure(NetworkFailureKind.offline);
        }
      },
    )..start();

    await tester.pump(const Duration(seconds: 3)); // first failure
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 5)); // next pause is 6 s
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 2);
    failing = false;
    await tester.pump(const Duration(seconds: 12)); // the third try, 12 s later, works
    expect(calls, 3);
    await tester.pump(const Duration(seconds: 3));
    expect(calls, 4, reason: 'back to the normal pause');
    poller.stop();
  });

  testWidgets('honours Retry-After on a throttled tick', (tester) async {
    var calls = 0;
    final poller = Poller(
      interval: () => interval,
      onTick: () async {
        calls++;
        if (calls == 1) {
          throw const ThrottledFailure(retryAfter: Duration(seconds: 20));
        }
      },
    )..start();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 19));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 2);
    poller.stop();
  });

  testWidgets('never waits longer than the cap', (tester) async {
    var calls = 0;
    final poller = Poller(
      interval: () => interval,
      maxBackoff: const Duration(seconds: 10),
      onTick: () async {
        calls++;
        throw const UnexpectedFailure(statusCode: 500);
      },
    )..start();

    await tester.pump(const Duration(minutes: 2));
    expect(calls, greaterThan(10));
    poller.stop();
  });

  testWidgets('stops by itself when the session ends', (tester) async {
    final poller = Poller(interval: () => interval, onTick: () async => throw const UnauthenticatedFailure())..start();

    await tester.pump(const Duration(seconds: 3));

    expect(poller.isRunning, isFalse);
  });
}
