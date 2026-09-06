import 'reactive_base.dart';

/// ---------------------------------------------------------------------------
/// Reactive dependency tracker
/// ---------------------------------------------------------------------------

/// Tracks accessed [ReactiveBase] instances during widget builds.
///
/// Used internally by `Watch` to automatically detect
/// reactive dependencies without requiring manual registration.
///
/// Workflow:
/// 1. [start] begins dependency tracking.
/// 2. Reactive values call [record] when accessed.
/// 3. [stop] returns all tracked dependencies.
class ReactiveTracker {
  ReactiveTracker._();

  /// Stack of tracked reactive dependency sets for nested tracking frames.
  static final List<Set<ReactiveBase>> _stack = [];

  /// Indicates whether tracking is currently active.
  static bool get isTracking => _stack.isNotEmpty;

  /// Starts dependency tracking by pushing a new frame onto the stack.
  static void start() {
    _stack.add({});
  }

  /// Stops dependency tracking for the top frame and returns tracked dependencies.
  static Set<ReactiveBase> stop() {
    if (_stack.isNotEmpty) {
      return _stack.removeLast();
    }
    return {};
  }

  /// Records a reactive dependency in the active tracking frame.
  ///
  /// Called internally by reactive value getters when tracking is active.
  static void record(ReactiveBase reactive) {
    if (_stack.isNotEmpty) {
      _stack.last.add(reactive);
    }
  }
}
