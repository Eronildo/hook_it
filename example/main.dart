import 'package:flutter/material.dart';
import 'package:hook_it/hook_it.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.use(() => ValueNotifier(0), id: 'counter');

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            '${counter.value}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => counter.value++,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
