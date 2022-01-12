import 'package:fake_async/fake_async.dart';
import 'package:frock/frock.dart';
import 'package:test/test.dart';

void main() {
  test('simple', () async {
    final lt = PlainLifetime();
    final sync = RepeatableSync<int>(lt);
    await sync.applyFetch(RepeatableSyncFetchDelegate(() {
      return Future.delayed(const Duration(seconds: 10), () => 5);
    }));
    expect(sync.state.data, equals(5));
  });

  test(
      'simple2',
      () => fakeAsync<void>((async) {
            final lt = PlainLifetime();
            final sync = RepeatableSync<int>(lt);
            sync.applyFetch(RepeatableSyncFetchDelegate(() {
              return Future.delayed(const Duration(seconds: 10), () => 5);
            }));
            async.flushTimers();
            expect(sync.state.data, equals(5));
          }));

  test(
      'simple3',
      () => fakeAsync<void>((async) {
            final lt = PlainLifetime();
            final sync = RepeatableSync<int>(lt);
            var eventN = 0;
            sync.updates.observe(lt, (_) {
              if (eventN == 0) {
                expect(sync.state.syncing, equals(true));
                expect(sync.state.data, equals(null));
              } else if (eventN == 1) {
                expect(sync.state.syncing, equals(false));
                expect(sync.state.data, equals(5));
              } else {
                assert(false);
              }
              eventN++;
            });
            sync.applyFetch(RepeatableSyncFetchDelegate(() {
              return Future.delayed(const Duration(seconds: 10), () => 5);
            }));
            async.flushTimers();
            expect(eventN, equals(2));
            expect(sync.state.data, equals(5));
          }));
}
