import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

void main() {
  testWidgets('Watch rebuilds when reactive value changes', (tester) async {
    final counter = Reactive<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: Watch(
          builder: () => Text('Count: ${counter.value}'),
        ),
      ),
    );

    expect(find.text('Count: 0'), findsOneWidget);

    counter.value = 1;
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget);
  });

  testWidgets('Watch.builder rebuilds with context and child', (tester) async {
    final counter = Reactive<int>(5);

    await tester.pumpWidget(
      MaterialApp(
        home: Watch.builder(
          child: const Text('Static Child'),
          builder: (context, child) => Column(
            children: [
              Text('Count: ${counter.value}'),
              child!,
            ],
          ),
        ),
      ),
    );

    expect(find.text('Count: 5'), findsOneWidget);
    expect(find.text('Static Child'), findsOneWidget);

    counter.value = 10;
    await tester.pump();

    expect(find.text('Count: 10'), findsOneWidget);
    expect(find.text('Static Child'), findsOneWidget);
  });

  testWidgets('Nested Watch widgets track dependencies independently', (tester) async {
    final outerCounter = Reactive<int>(10);
    final innerCounter = Reactive<int>(20);

    await tester.pumpWidget(
      MaterialApp(
        home: Watch(
          builder: () => Column(
            children: [
              Text('Outer: ${outerCounter.value}'),
              Watch(
                builder: () => Text('Inner: ${innerCounter.value}'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Outer: 10'), findsOneWidget);
    expect(find.text('Inner: 20'), findsOneWidget);

    // Updating outer counter should trigger outer rebuild
    outerCounter.value = 11;
    await tester.pump();
    expect(find.text('Outer: 11'), findsOneWidget);

    // Updating inner counter should trigger inner rebuild
    innerCounter.value = 21;
    await tester.pump();
    expect(find.text('Inner: 21'), findsOneWidget);
  });
}
