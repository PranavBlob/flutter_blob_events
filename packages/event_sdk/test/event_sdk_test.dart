import 'package:event_sdk/event_sdk.dart';
import 'package:test/test.dart';

class _FakeAdapter implements EventAdapter {
  _FakeAdapter(this.platform);

  @override
  final EventPlatform platform;

  final List<Event> tracked = [];
  final List<String> identified = [];
  int initCount = 0;
  bool throwOnTrack = false;

  @override
  Future<void> init() async {
    initCount++;
  }

  @override
  Future<void> track(Event event) async {
    if (throwOnTrack) {
      throw StateError('boom-${platform.name}');
    }
    tracked.add(event);
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    identified.add(userId);
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  tearDown(EventSdk.debugReset);

  test('routes track to all enabled adapters by default', () async {
    final aws = _FakeAdapter(EventPlatform.aws);
    final adjust = _FakeAdapter(EventPlatform.adjust);

    await EventSdk.init([aws, adjust]);
    await EventSdk.track('signup', props: {'method': 'email'});

    expect(aws.tracked, hasLength(1));
    expect(adjust.tracked, hasLength(1));
    expect(aws.tracked.single.name, 'signup');
    expect(aws.tracked.single.props['method'], 'email');
  });

  test('exclude skips selected platforms', () async {
    final aws = _FakeAdapter(EventPlatform.aws);
    final adjust = _FakeAdapter(EventPlatform.adjust);

    await EventSdk.init([aws, adjust]);
    await EventSdk.track('purchase', exclude: [EventPlatform.adjust]);

    expect(aws.tracked, hasLength(1));
    expect(adjust.tracked, isEmpty);
  });

  test('only targets selected platforms', () async {
    final aws = _FakeAdapter(EventPlatform.aws);
    final adjust = _FakeAdapter(EventPlatform.adjust);

    await EventSdk.init([aws, adjust]);
    await EventSdk.track('open', only: [EventPlatform.aws]);

    expect(aws.tracked, hasLength(1));
    expect(adjust.tracked, isEmpty);
  });

  test('rejects exclude and only together', () async {
    await EventSdk.init([
      _FakeAdapter(EventPlatform.aws),
    ]);

    expect(
      () => EventSdk.track(
        'x',
        exclude: [EventPlatform.aws],
        only: [EventPlatform.aws],
      ),
      throwsA(isA<EventSdkException>()),
    );
  });

  test('disable removes platform until re-enabled', () async {
    final aws = _FakeAdapter(EventPlatform.aws);
    final adjust = _FakeAdapter(EventPlatform.adjust);

    await EventSdk.init([aws, adjust]);
    EventSdk.disable(EventPlatform.adjust);
    await EventSdk.track('a');
    EventSdk.enable(EventPlatform.adjust);
    await EventSdk.track('b');

    expect(aws.tracked.map((e) => e.name), ['a', 'b']);
    expect(adjust.tracked.map((e) => e.name), ['b']);
  });

  test('failSoft swallows adapter errors by default', () async {
    final aws = _FakeAdapter(EventPlatform.aws)..throwOnTrack = true;
    final adjust = _FakeAdapter(EventPlatform.adjust);
    final errors = <Object>[];

    await EventSdk.init(
      [aws, adjust],
      config: EventSdkConfig(onAdapterError: (e, _) => errors.add(e)),
    );
    await EventSdk.track('x');

    expect(adjust.tracked, hasLength(1));
    expect(errors, hasLength(1));
  });

  test('duplicate adapters are rejected', () async {
    expect(
      () => EventSdk.init([
        _FakeAdapter(EventPlatform.aws),
        _FakeAdapter(EventPlatform.aws),
      ]),
      throwsA(isA<EventSdkException>()),
    );
  });

  test('merges default params into every platform', () async {
    final aws = _FakeAdapter(EventPlatform.aws);
    final adjust = _FakeAdapter(EventPlatform.adjust);

    await EventSdk.init(
      [aws, adjust],
      config: const EventSdkConfig(
        defaultParams: {'source': 'app', 'env': 'dev'},
      ),
    );
    await EventSdk.track('signup', props: {'method': 'email'});

    final expected = {
      'source': 'app',
      'env': 'dev',
      'method': 'email',
    };
    expect(aws.tracked.single.props, expected);
    expect(adjust.tracked.single.props, expected);
  });

  test('track props override default params with same key', () async {
    final aws = _FakeAdapter(EventPlatform.aws);

    await EventSdk.init(
      [aws],
      config: const EventSdkConfig(defaultParams: {'env': 'dev'}),
    );
    await EventSdk.track('signup', props: {'env': 'prod'});

    expect(aws.tracked.single.props['env'], 'prod');
  });

  test('setDefaultParam updates a key for later events', () async {
    final aws = _FakeAdapter(EventPlatform.aws);
    final firebase = _FakeAdapter(EventPlatform.firebase);

    await EventSdk.init(
      [aws, firebase],
      config: const EventSdkConfig(defaultParams: {'userType': 'guest'}),
    );
    EventSdk.setDefaultParam('userId', 'user_123');
    EventSdk.setDefaultParam('userType', 'premium');
    await EventSdk.track('open');

    expect(aws.tracked.single.props, {
      'userType': 'premium',
      'userId': 'user_123',
    });
    expect(firebase.tracked.single.props['userId'], 'user_123');
  });

  test('updateDefaultParams merges at runtime', () async {
    final aws = _FakeAdapter(EventPlatform.aws);

    await EventSdk.init([aws]);
    EventSdk.updateDefaultParams({'userType': 'guest'});
    await EventSdk.track('open');

    expect(aws.tracked.single.props['userType'], 'guest');
  });
}
