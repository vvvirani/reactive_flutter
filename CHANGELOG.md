## 1.0.6

- Add `Watch.builder` constructor with `BuildContext` access and `child` widget rebuild optimization
- Fix stack-based tracking in `ReactiveTracker` to prevent nested tracking frames from clobbering parent dependencies
- Fix state notification tracking bug when accessing reactive values inside deferred builders (`Watch -> Builder`)
- Pass `BuildContext` and optional `child` parameter directly to `Watch.builder` callbacks
- Update examples and documentation for `Watch` and `Watch.builder`

## 1.0.5

- Add `ReactiveIsolateTask` for reactive background isolate execution
- Add `ReactiveTaskState` with loading, data, and error handling
- Add `ReactiveTaskPayload` for reusable isolate task definitions
- Add `run()` and `runOrThrow()` isolate execution methods
- Add reactive isolate state tracking
- Add reusable generic isolate task architecture
- Improve heavy task handling without blocking UI
- Improve large file reading and parsing performance
- Add isolate task reset support
- Add documentation and examples for isolate usage

## 1.0.4

- Fix `LoggerView` filter — ALL mode now correctly shows all lines
- Fix `_visible` getter reactive tracking inside `Watch`
- Fix `No Overlay widget found` error in `LoggerOverlay`
- Fix `Row` and `Column` overflow in `LoggerView`
- Remove `Tooltip` dependency on `Overlay` ancestor
- Add `useOverlay` parameter to `LoggerView.open()`

## 1.0.3

- Add `ReactiveLogger` with plain `.log` file output
- Add `LoggerView` with level-based color coding
- Add `LoggerOverlay` floating debug button
- Add `ClearPolicy` — daily, weekly, monthly, 3 month, 6 month auto-clear
- Add `LogLevel` — debug, info, warning, error, fatal

## 1.0.2

- Add `ReactivePagination` with `PaginationState` and `copyWith`
- Add `ReactiveCursorPagination` for Firebase, GraphQL, Supabase
- Add `ReactiveSearch` with debounce, min length, stale guard

## 1.0.1

- Add `ReactiveInjector` singleton and transient DI
- Add `Inject` static facade
- Fix `PaginationState` `List<Never>` type error

## 1.0.0

- Initial release
- `Reactive<T>` auto-tracking state container
- `Watch` widget with zero-config dependency detection
- `ReactiveBase` and `ReactiveTracker` internals