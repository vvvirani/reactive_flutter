import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../reactive_base.dart';
import '../reactive_tracker.dart';

/// ---------------------------------------------------------------------------
/// Reactive widget observer
/// ---------------------------------------------------------------------------

/// A widget that automatically rebuilds when any accessed `Reactive`
/// value changes.
///
/// Dependencies are detected automatically by tracking
/// which reactive values are accessed during the [builder] execution.
///
/// No manual dependency list is required.
///
/// Example:
/// ```dart
/// Watch(
///   builder: () => Column(
///     children: [
///       Text('${counter.value}'),
///       Text(name.value),
///       Switch(
///         value: isDark.value,
///         onChanged: (v) => isDark.value = v,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Conditional dependencies are also supported:
///
/// ```dart
/// Watch(
///   builder: () => isDark.value
///       ? Text(darkLabel.value)
///       : Text(lightLabel.value),
/// )
/// ```
///
/// In this case:
/// - `darkLabel` is only tracked when `isDark == true`
/// - `lightLabel` is only tracked when `isDark == false`
typedef WatchBuilder = Widget Function(BuildContext context, Widget? child);

/// A widget that automatically rebuilds when any accessed `Reactive`
/// value changes.
///
/// Dependencies are detected automatically by tracking
/// which reactive values are accessed during the [builder] execution.
///
/// No manual dependency list is required.
///
/// Example:
/// ```dart
/// Watch(
///   builder: () => Column(
///     children: [
///       Text('${counter.value}'),
///       Text(name.value),
///       Switch(
///         value: isDark.value,
///         onChanged: (v) => isDark.value = v,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// With [BuildContext] and [child] optimization using [Watch.builder]:
/// ```dart
/// Watch.builder(
///   builder: (context, child) => Column(
///     children: [
///       Text('${counter.value}'),
///       child!,
///     ],
///   ),
///   child: const ExpensiveWidget(),
/// )
/// ```
class Watch extends StatefulWidget {
  final Widget Function()? _noArgsBuilder;
  final WatchBuilder? _builderWithChild;

  /// Optional child widget passed to [builder] that does not rebuild when reactive values change.
  final Widget? child;

  /// Creates a [Watch] widget using a no-argument builder callback.
  const Watch({
    super.key,
    required Widget Function() builder,
  })  : _noArgsBuilder = builder,
        _builderWithChild = null,
        child = null;

  /// Creates a [Watch] widget with [BuildContext] access and optional [child] optimization.
  const Watch.builder({
    super.key,
    required WatchBuilder builder,
    this.child,
  })  : _noArgsBuilder = null,
        _builderWithChild = builder;

  /// Invokes the appropriate builder with [context] and [child].
  Widget buildChild(BuildContext context, Widget? child) {
    if (_builderWithChild != null) {
      return _builderWithChild!(context, child);
    }
    return _noArgsBuilder!();
  }

  @override
  State<Watch> createState() => _WatchState();
}

/// Internal state for [Watch].
class _WatchState extends State<Watch> {
  /// Currently subscribed reactive dependencies.
  Set<ReactiveBase> _subscribed = {};

  /// Shared listener attached to all tracked dependencies.
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();

    _listener = _onNotify;

    // Initial dependency collection before the first real build.
    _collectDependencies();
  }

  /// Called when any subscribed reactive dependency changes.
  void _onNotify() {
    if (mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  /// Executes the builder while dependency tracking is enabled.
  ///
  /// Used to discover all accessed reactive dependencies.
  void _collectDependencies() {
    ReactiveTracker.start();

    widget.buildChild(context, widget.child);

    final Set<ReactiveBase> dependencies = ReactiveTracker.stop();

    _updateSubscriptions(dependencies);
  }

  /// Updates reactive subscriptions.
  ///
  /// Removes old listeners and subscribes to new dependencies.
  void _updateSubscriptions(Set<ReactiveBase> newDependencies) {
    if (setEquals(newDependencies, _subscribed)) {
      return;
    }

    for (final ReactiveBase reactive in _subscribed) {
      reactive.removeListener(_listener);
    }

    _subscribed = newDependencies;

    for (final ReactiveBase reactive in _subscribed) {
      reactive.addListener(_listener);
    }
  }

  @override
  void didUpdateWidget(Watch oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recollect dependencies if the builder or child changes.
    if (oldWidget._noArgsBuilder != widget._noArgsBuilder ||
        oldWidget._builderWithChild != widget._builderWithChild ||
        oldWidget.child != widget.child) {
      _collectDependencies();
    }
  }

  @override
  void dispose() {
    for (final ReactiveBase reactive in _subscribed) {
      reactive.removeListener(_listener);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Real build with dependency tracking enabled.
    ReactiveTracker.start();

    final Widget result = widget.buildChild(context, widget.child);

    final Set<ReactiveBase> dependencies = ReactiveTracker.stop();

    _updateSubscriptions(dependencies);

    return result;
  }
}
