import 'package:flutter/widgets.dart';
import 'package:mobile_fitness_app/app/dependencies.dart';

class DependencyScope extends InheritedWidget {
  final Dependencies deps;

  const DependencyScope({
    super.key,
    required this.deps,
    required super.child,
  });

  static Dependencies of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DependencyScope>();
    assert(scope != null, 'DependencyScope not found in widget tree');
    return scope!.deps;
  }

  @override
  bool updateShouldNotify(DependencyScope oldWidget) {
    return false;
  }
}
