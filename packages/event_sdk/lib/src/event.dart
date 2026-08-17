/// Normalized event passed to every [EventAdapter].
class Event {
  const Event({
    required this.name,
    this.props = const {},
    this.timestamp,
  });

  final String name;
  final Map<String, Object?> props;
  final DateTime? timestamp;

  Event copyWith({
    String? name,
    Map<String, Object?>? props,
    DateTime? timestamp,
  }) {
    return Event(
      name: name ?? this.name,
      props: props ?? this.props,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() => 'Event(name: $name, props: $props, timestamp: $timestamp)';
}
