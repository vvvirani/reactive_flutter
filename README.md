![reactive\_flutter banner](https://raw.githubusercontent.com/vvvirani/reactive_flutter/main/assets/reactive_flutter_banner.png)

[![pub package](https://img.shields.io/pub/v/reactive_flutter.svg)](https://pub.dev/packages/reactive_flutter)
[![likes](https://img.shields.io/pub/likes/reactive_flutter)](https://pub.dev/packages/reactive_flutter/score)
[![popularity](https://img.shields.io/pub/popularity/reactive_flutter)](https://pub.dev/packages/reactive_flutter/score)
[![pub points](https://img.shields.io/pub/points/reactive_flutter)](https://pub.dev/packages/reactive_flutter/score)

A lightweight auto-tracking reactive state management library for Flutter.

`reactive_flutter` provides:

* Reactive state containers
* Automatic widget rebuild tracking
* Lightweight dependency injection
* Page-based pagination
* Cursor-based pagination
* Reactive search
* Reactive logger
* Minimal boilerplate
* Zero code generation

---

# Wiki

* [About](#about)
* [Features](#features)
* [Installation](https://pub.dev/packages/reactive_flutter/install)
* [Quick Start](#quick-start)
* [Reactive State](#reactive-state)

  * [Create Reactive Values](#create-reactive-values)
  * [Reading Values](#reading-values)
  * [Updating Values](#updating-values)
  * [Silent Updates](#silent-updates)
* [Watch Widget](#watch-widget)

  * [Basic Example](#basic-example)
  * [Watch Builder with Context and Child](#watch-builder-with-context-and-child)
  * [Multiple Reactive Dependencies](#multiple-reactive-dependencies)
  * [Conditional Tracking](#conditional-tracking)
  * [Nested Watch Example](#nested-watch-example)
* [Dependency Injection](#dependency-injection)

  * [Register Singleton](#register-singleton)
  * [Register Transient](#register-transient)
  * [Check Registration](#check-registration)
  * [Reset Singleton](#reset-singleton)
  * [Unregister Dependency](#unregister-dependency)
  * [Clear All Dependencies](#clear-all-dependencies)
* [Page-Based Pagination](#page-based-pagination)

  * [Initialize Pagination](#initialize-pagination)
  * [Refresh Pagination](#refresh-pagination)
  * [Load More](#load-more)
  * [Watch Pagination State](#watch-pagination-state)
  * [Scroll Pagination Example](#scroll-pagination-example)
* [Cursor-Based Pagination](#cursor-based-pagination)

  * [PaginationResult](#paginationresult)
  * [Cursor Pagination State](#cursor-pagination-state)
* [Reactive Search](#reactive-search)

  * [Create Search Controller](#create-search-controller)
  * [Debounced Search](#debounced-search)
  * [Manual Search](#manual-search)
  * [Clear Search](#clear-search)
  * [Watch Search State](#watch-search-state)
* [Reactive Isolate Tasks](#reactive-isolate-tasks)

  * [Create Isolate Task](#create-isolate-task)
  * [Run Task](#run-task)
  * [Watch Task State](#watch-task-state)
  * [Handle Errors](#handle-errors)
  * [Heavy Task Example](#heavy-task-example)
* [Reactive Logger](#reactive-logger)

  * [Initialize Logger](#initialize-logger)
  * [Write Logs](#write-logs)
  * [Read Logs](#read-logs)
  * [Clear Logs](#clear-logs)
  * [Delete Logs](#delete-logs)
  * [Logger State](#logger-state)
* [API Overview](#api-overview)
* [Performance](#performance)
* [Architecture](#architecture)
* [Comparison](#comparison)
* [Best Practices](#best-practices)
* [When to Use reactive_flutter](#when-to-use-reactive_flutter)
* [Advanced Examples](#advanced-reactive-example)
* [Unit Testing](#unit-testing-example)
* [FAQ](#faq)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)

---

# About

`reactive_flutter` is designed to provide a lightweight and minimal reactive architecture for Flutter applications.

It focuses on:

* Simplicity
* Performance
* Automatic dependency tracking
* Minimal boilerplate
* Easy integration

---

# Features

```md
✅ Automatic dependency tracking  
✅ Lightweight and fast  
✅ No `BuildContext` required for state access  
✅ No manual dependency lists  
✅ No code generation  
✅ Page-based pagination  
✅ Cursor-based pagination  
✅ Reactive search with debounce  
✅ Reactive logger  
✅ Simple dependency injection  
✅ Easy to learn and use
✅ Background isolate task execution  
✅ Reactive isolate task state  
✅ Heavy computation without UI freeze  
✅ Generic isolate task payloads   
```

---

# Quick Start

```dart
final Reactive<int> counter = Reactive<int>(0);

Watch(
  builder: () {
    return Text('${counter.value}');
  },
)
```

Update state:

```dart
counter.value++;
```

---

# Reactive State

`Reactive<T>` is a lightweight reactive value holder.

Whenever the value changes, widgets that depend on it automatically rebuild.

---

## Create Reactive Values

```dart
final Reactive<int> counter = Reactive<int>(0);

final Reactive<String> title = Reactive<String>('Flutter');

final Reactive<bool> isDark = Reactive<bool>(false);
```

---

## Reading Values

Use `.value` to access the current value.

```dart
print(counter.value);
```

---

## Updating Values

```dart
counter.value++;

isDark.value = true;
```

---

## Silent Updates

Use `setSilent()` to update a value without notifying listeners.

```dart
counter.setSilent(100);
```

---

# Watch Widget

`Watch` automatically rebuilds whenever a reactive value used inside the builder changes.

No dependency list is required.

---

## Basic Example

```dart
Watch(
  builder: () {
    return Text('${counter.value}');
  },
)
```

---

## Watch Builder with Context and Child

Use `Watch.builder` when you need access to `BuildContext` or want to prevent expensive child subtrees from rebuilding when reactive values change:

```dart
Watch.builder(
  builder: (context, child) {
    return Column(
      children: [
        Text(
          'Count: ${counter.value}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        child!,
      ],
    );
  },
  child: const HeavyComplexWidget(),
)
```

---

## Multiple Reactive Dependencies

```dart
Watch(
  builder: () {
    return Column(
      children: [
        Text('${counter.value}'),

        Text(title.value),

        Switch(
          value: isDark.value,
          onChanged: (value) {
            isDark.value = value;
          },
        ),
      ],
    );
  },
)
```

---

## Conditional Tracking

Dependencies are tracked automatically based on what is accessed during build.

```dart
Watch(
  builder: () {
    return isDark.value
        ? const Text('Dark Mode')
        : const Text('Light Mode');
  },
)
```

Only the active branch is subscribed.

---

## Nested Watch Example

```dart
Watch(
  builder: () {
    return Column(
      children: [
        Watch(
          builder: () {
            return Text(
              counter.value.toString(),
            );
          },
        ),

        Watch(
          builder: () {
            return Text(title.value);
          },
        ),
      ],
    );
  },
)
```

---

# Dependency Injection

`ReactiveInjector` is a lightweight service locator.

Supports:

* Singleton registration
* Transient registration
* Dependency lookup
* Reset
* Unregister
* Clear all

---

## Register Singleton

```dart
ReactiveInjector.singleton<ApiService>(() => ApiService());
```

Retrieve dependency:

```dart
final ApiService api = ReactiveInjector.find<ApiService>();
```

---

## Register Transient

```dart
ReactiveInjector.transient<UserRepository>(() => UserRepository());
```

---

## Check Registration

```dart
final bool exists = ReactiveInjector.isRegistered<ApiService>();
```

---

## Reset Singleton

```dart
ReactiveInjector.reset<ApiService>();
```

---

## Unregister Dependency

```dart
ReactiveInjector.unregister<ApiService>();
```

---

## Clear All Dependencies

```dart
ReactiveInjector.clear();
```

---

# Page-Based Pagination

`ReactivePagination<T>` helps manage paginated APIs using page numbers.

---

## Create Pagination Controller

```dart
final ReactivePagination<User> pagination = ReactivePagination<User>(
  perPage: 20,
  fetcher: (page, perPage) async {
    return api.fetchUsers(page, perPage);
  },
);
```

---

## Initialize Pagination

```dart
await pagination.init();
```

---

## Refresh Pagination

```dart
await pagination.refresh();
```

---

## Load More

```dart
await pagination.fetchMore();
```

---

## Watch Pagination State

```dart
Watch(
  builder: () {
    if (pagination.isLoading) {
      return const CircularProgressIndicator();
    }

    return ListView.builder(
      itemCount: pagination.items.length,
      itemBuilder: (context, index) {
        final User user = pagination.items[index];

        return ListTile(title: Text(user.name));
      },
    );
  },
)
```

---

## Scroll Pagination Example

```dart
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ScrollController controller =ScrollController();

  final ReactivePagination<User> pagination = ReactivePagination<User>(
    perPage: 20,
    fetcher: (page, limit) async {
      return api.fetchUsers(page, limit);
    },
  );

  @override
  void initState() {
    super.initState();

    pagination.init();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent -
              200) {
        pagination.fetchMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      builder: () {
        return ListView.builder(
          controller: controller,
          itemCount: pagination.items.length,
          itemBuilder: (context, index) {
            final User user = pagination.items[index];

            return ListTile(title: Text(user.name));
          },
        );
      },
    );
  }
}
```

---

# Cursor-Based Pagination

`ReactiveCursorPagination<T, C>` supports cursor-based APIs.

Examples of cursor types:

* `String`
* `int`
* `DateTime`
* `DocumentSnapshot` (Firebase Firestore)
* Firestore document snapshots
* Custom models

---

## Create Cursor Pagination

```dart
final ReactiveCursorPagination<User, String>
    pagination =
    ReactiveCursorPagination<User, String>(
  perPage: 20,
  fetcher: (perPage, cursor) async {
    return api.fetchUsers(perPage, cursor);
  },
);
```

---

## PaginationResult

```dart
PaginationResult<User, String>(
  items: users,
  nextCursor: nextCursor,
)
```

---

## Cursor Pagination State

```dart
pagination.items
pagination.cursor
pagination.isLoading
pagination.isMoreLoading
pagination.hasMore
pagination.error
pagination.totalFetched
pagination.isEmpty
```

---

# Reactive Search

`ReactiveSearch<T>` provides debounced reactive searching.

Features:

* Debounced queries
* Idle/loading/error states
* Stale request protection
* Automatic rebuilding

---

## Create Search Controller

```dart
final ReactiveSearch<User> search =
    ReactiveSearch<User>(
  debounceMs: 500,
  minLength: 2,
  fetcher: (query) async {
    return api.searchUsers(query);
  },
);
```

---

## Debounced Search

```dart
TextField(onChanged: search.onChanged)
```

---

## Manual Search

```dart
await search.search('flutter');
```

---

## Clear Search

```dart
search.clear();
```

---

## Watch Search State

```dart
Watch(
  builder: () {
    if (search.isLoading) {
      return const CircularProgressIndicator();
    }

    if (search.isEmpty) {
      return const Text('No results');
    }

    return ListView.builder(
      itemCount: search.results.length,
      itemBuilder: (context, index) {
        final User user = search.results[index];
        return ListTile(title: Text(user.name));
      },
    );
  },
)
```

---

# Reactive Isolate Tasks

`ReactiveIsolateTask<T>` provides reactive isolate execution for heavy background operations.

Features:

* Background isolate execution
* Reactive loading state
* Reactive error handling
* Generic reusable task payloads
* Non-blocking UI updates

# Create Isolate Task

```dart
final ReactiveIsolateTask<int> task = ReactiveIsolateTask<int>();
```

# Run Task

```dart
await task.run<int>(
  ReactiveTaskPayload(input: 1000000, allback: heavyCalculation),
);
```

# Watch Task State

```dart
Watch(
  builder: () {
    if (task.isLoading) {
      return const CircularProgressIndicator();
    }

    if (task.error != null) {
      return Text(task.error.toString());
    }

    return Text('Result: ${task.data}');
  },
)
```

# Handle Errors

```dart
await task.run<String>(
  ReactiveTaskPayload(
    input: 'data',
    callback: (value) {
      throw Exception('Something failed');
    },
  ),
);

print(task.error);
```

# Heavy Task Example

```dart
int heavyCalculation(int total) {
  int sum = 0;

  for (int i = 0; i < total; i++) {
    sum += i;
  }

  return sum;
}

await task.run<int>(
  ReactiveTaskPayload(
    input: 10000000,
    callback: heavyCalculation,
  ),
);
```

---

# Reactive Logger

`ReactiveLogger` is a lightweight persistent logger with reactive state support.

Features:

* File-based logs
* Auto-clear policies
* Buffered writes
* Console output
* Error & stack trace logging
* Reactive logger state

---

## Initialize Logger

```dart
final ReactiveLogger logger = ReactiveLogger(fileName: 'app_logs', clearPolicy: ClearPolicy.weekly);
await logger.init();
```

---

## Write Logs

```dart
logger.debug('Debug message');

logger.info('User logged in');

logger.warning('Slow API response');

logger.error('Request failed', error: exception, stack: stackTrace);

logger.fatal('Critical failure');
```

---

## Read Logs

```dart
  LoggerView.open(context, logger: logger);
```

---

## Clear Logs

```dart
await logger.clearFile();
```

---

## Delete Logs

```dart
await logger.deleteFile();
```

---

## Logger State

```dart
logger.value.totalLogs
logger.value.lastCleared
logger.value.isReady
```

---

# API Overview

## Reactive

| Function      | Description                  |
| ------------- | ---------------------------- |
| `value`       | Get or update reactive value |
| `setSilent()` | Update without notifying     |
| `toString()`  | Debug string                 |

---

## Watch

| Property  | Description                 |
| --------- | --------------------------- |
| `builder` | Auto-tracked widget builder |

---

## ReactiveInjector

| Function         | Description             |
| ---------------- | ----------------------- |
| `singleton()`    | Register singleton      |
| `transient()`    | Register transient      |
| `find()`         | Resolve dependency      |
| `isRegistered()` | Check registration      |
| `reset()`        | Reset singleton         |
| `unregister()`   | Remove dependency       |
| `clear()`        | Remove all dependencies |

---

## ReactivePagination

| Function      | Description       |
| ------------- | ----------------- |
| `init()`      | Load first page   |
| `refresh()`   | Reload pagination |
| `fetchMore()` | Load next page    |

---

## ReactiveCursorPagination

| Function      | Description            |
| ------------- | ---------------------- |
| `init()`      | Load first cursor page |
| `refresh()`   | Reload pagination      |
| `fetchMore()` | Load next cursor page  |

---

## ReactiveSearch

| Function      | Description      |
| ------------- | ---------------- |
| `onChanged()` | Debounced search |
| `search()`    | Manual search    |
| `clear()`     | Reset search     |
| `results`     | Current results  |
| `isLoading`   | Loading state    |
| `isIdle`      | Idle state       |
| `isEmpty`     | Empty state      |
| `error`       | Current error    |

---

## ReactiveIsolateTask

| Function       | Description                      |
| -------------- | -------------------------------- |
| `run()`        | Run isolate task safely          |
| `runOrThrow()` | Run isolate task and throw error |
| `reset()`      | Reset task state                 |
| `isLoading`    | Current loading state            |
| `data`         | Latest task result               |
| `error`        | Latest task error                |


## ReactiveLogger

| Function       | Description       |
| -------------- | ----------------- |
| `debug()`      | Write debug log   |
| `info()`       | Write info log    |
| `warning()`    | Write warning log |
| `error()`      | Write error log   |
| `fatal()`      | Write fatal log   |
| `clearFile()`  | Clear log file    |
| `deleteFile()` | Delete log file   |
| `readRaw()`    | Read raw log      |
| `readLines()`  | Read log lines    |

---

# Performance

`reactive_flutter` is designed to stay lightweight and fast.

## Why it performs well

* No reflection
* No code generation
* Fine-grained rebuild tracking
* Minimal allocations
* Conditional dependency tracking
* Only subscribed widgets rebuild
* Background isolate execution for heavy operations
* Large file parsing without blocking UI
* Reactive async task state management

---

# Architecture

```text
Reactive<T>
    ↓
ReactiveTracker
    ↓
Watch Widget
    ↓
Automatic Rebuild
```

## How it works

1. `Watch` starts dependency tracking
2. Accessed reactive values register themselves
3. `Watch` subscribes only to used reactives
4. Changed reactives rebuild subscribed widgets

---

# Comparison

| Feature                    | reactive_flutter | GetX       | Riverpod    | Provider |
| -------------------------- | ---------------- | ---------- | ----------- | -------- |
| Auto tracking              | ✅                | ⚠️ Partial | ❌           | ❌        |
| Code generation            | ❌                | ❌          | ⚠️ Optional | ❌        |
| Boilerplate                | Very Low         | Low        | Medium      | Medium   |
| Dependency injection       | ✅                | ✅          | ❌           | ❌        |
| Pagination helpers         | ✅                | ❌          | ❌           | ❌        |
| Reactive search            | ✅                | ❌          | ❌           | ❌        |
| Reactive logger            | ✅                | ❌          | ❌           | ❌        |
| Reactive isolate tasks     | ✅                | ❌          | ❌           | ❌        |
| Automatic rebuild tracking | ✅                | ⚠️ Partial | ❌           | ❌        |
| Zero-config watchers       | ✅                | ⚠️         | ❌           | ❌        |
| Learning curve             | Easy             | Easy       | Medium      | Easy     |
| Lightweight                | ✅                | ⚠️         | ⚠️          | ✅        |
| No BuildContext access     | ✅                | ✅          | ✅           | ❌        |

---

# Best Practices

* Keep reactive values focused and small
* Prefer multiple small reactives
* Use nested `Watch` widgets for granular rebuilds
* Dispose controllers when needed
* Avoid unnecessary global state

---

# When to Use reactive_flutter

`reactive_flutter` works especially well for:

* Small to medium apps
* Utility applications
* MVPs & prototypes
* Admin panels
* Feature modules
* Teams preferring lightweight architecture

---

# Advanced Reactive Example

```dart
final Reactive<List<String>> todos = Reactive<List<String>>([]);

void addTodo(String value) {
  todos.value = [ ...todos.value, value ];
}

void removeTodo(String value) {
  todos.value = todos.value.where((e) => e != value).toList();
}
```

---

# Unit Testing Example

```dart
void main() {
  test(
    'Reactive value updates correctly',
    () {
      final Reactive<int> counter = Reactive<int>(0);

      counter.value = 5;

      expect(counter.value, 5);
    },
  );
}
```

---

# FAQ

## Does this use code generation?

No.

`reactive_flutter` works without generators or build_runner.

---

## Does Watch rebuild the whole app?

No.

Only widgets subscribed to changed reactive values rebuild.

---

## Can I use it with existing architectures?

Yes.

Works well with:

* Clean Architecture
* MVVM
* MVC
* Feature-first architecture

---

## Does it support async state?

Yes.

You can store async results, pagination state, and API responses inside reactive values.

---

## Is it production ready?

Yes.

The library is designed to be lightweight, predictable, and production friendly.

---

# Roadmap

Planned future improvements:

* [ ] Computed reactive values
* [ ] Reactive collections
* [ ] DevTools integration
* [ ] Async reactive helpers
* [ ] Stream bindings
* [ ] Form utilities
* [ ] Persistent storage helpers
* [ ] Flutter Web optimizations
* [ ] Isolate task pooling
* [ ] Parallel isolate execution helpers
* [ ] Cancelable isolate tasks

---

# Contributing

Contributions are welcome.

## Setup

```bash
git clone <repository>
cd reactive_flutter
flutter pub get
```

## Run Tests

```bash
flutter test
```

## Format Code

```bash
dart format .
```

---

# License

MIT License © V Developer
