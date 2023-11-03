# 🪝 Hook it

[![pub][pub_badge]][pub_link] [![License: MIT][license_badge]][license_link]

---

Hook the objects in a simple way with less boilerplate.
You can use it, listen it and dispose it in a single function inside the build method.

---

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:hook_it/hook_it.dart';

class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final focusNode = context.use(FocusNode.new, id: 'focusNode');
    final controller =
        context.use(TextEditingController.new, id: 'controller');

    return TextField(
        focusNode: focusNode,
        controller: controller,
    );
  }
}
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT

[pub_badge]: https://img.shields.io/pub/v/hook_it.svg
[pub_link]: https://pub.dev/packages/hook_it
