/// 🪝 The hook_it library for [Flutter](https://flutter.dev).
///
/// See [HookIt in GitHub](https://github.com/Eronildo/hook_it)
library hook_it;

import 'dart:collection';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

typedef CreateCallback<T> = T Function();
typedef ListenerCallback<T> = void Function(T hook);
typedef DisposeCallback<T> = void Function(T hook);

class _CallbackWrapper<T> {
  Future<bool> Function()? willPopCallback;
}

const _use_ = '_use_';
final _instances = HashMap<String, dynamic>();

/// Hook [T]
T use<T>(
  BuildContext context,
  CreateCallback<T> create, {
  required String id,
  ListenerCallback<T>? listener,
  DisposeCallback<T>? dispose,
}) =>
    _use<T>(context, id, create, listener: listener, dispose: dispose);

/// [BuildContext] extension.
extension BuildContextExtension on BuildContext {
  /// Hook [T]
  T use<T>(
    CreateCallback<T> create, {
    required String id,
    ListenerCallback<T>? listener,
    DisposeCallback<T>? dispose,
  }) =>
      _use<T>(this, id, create, listener: listener, dispose: dispose);
}

T _use<T extends dynamic>(
  BuildContext context,
  String id,
  CreateCallback<T> create, {
  ListenerCallback<T>? listener,
  DisposeCallback<T>? dispose,
}) {
  final key = '$_use_$id${context.hashCode}';
  return _instances.putIfAbsent(key, () {
    final hook = create();
    final callbackWrapper = _CallbackWrapper<T>();

    VoidCallback? listenerCallback;
    final isListanable = hook is Listenable;

    if (isListanable) {
      final elementRef = WeakReference(context as Element);

      listenerCallback = () {
        listener?.call(hook);
        assert(
          SchedulerBinding.instance.schedulerPhase !=
              SchedulerPhase.persistentCallbacks,
          'Trying to mutate during a `build` method.',
        );
        if (elementRef.target?.mounted ?? false) {
          elementRef.target!.markNeedsBuild();
        }
      };

      hook.addListener(listenerCallback);
    }

    final modalRoute = ModalRoute.of(context);

    if (modalRoute != null) {
      Future<bool> willPopCallback() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isListanable) {
            hook.removeListener(listenerCallback!);
          }

          dispose?.call(hook);

          try {
            hook?.dispose?.call();
            hook?.close?.call();
            hook?.clear?.call();
          } catch (_) {}

          modalRoute
              .removeScopedWillPopCallback(callbackWrapper.willPopCallback!);

          _instances.remove(key);
        });

        return Future.value(true);
      }

      callbackWrapper.willPopCallback = willPopCallback;
      modalRoute.addScopedWillPopCallback(callbackWrapper.willPopCallback!);
    }

    return hook;
  }) as T;
}
