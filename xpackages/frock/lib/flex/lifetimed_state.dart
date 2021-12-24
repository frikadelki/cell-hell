import 'package:flutter/widgets.dart';
import 'package:frock/runtime/frock_runtime.dart';

mixin LifetimedState<TWidget extends StatefulWidget> on State<TWidget> {
  final _lifetimes = PlainLifetimesAutoSequence();

  @override
  void initState() {
    super.initState();
    initLifetimedState(_lifetimes.lifetime);
    observeWidget(_lifetimes.next());
  }

  void initLifetimedState(Lifetime lifetime) {}

  @override
  void didUpdateWidget(TWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (compareWidgetState(oldWidget)) {
      return;
    }
    final next = _lifetimes.next();
    observeWidget(next);
  }

  // sort of a workaround for when we have some state in UI
  // derived from widget and we don't want to reset it when
  // actual data behind the widget and behind that state do
  // not change
  bool compareWidgetState(TWidget oldWidget) {
    return widget == oldWidget;
  }

  void observeWidget(Lifetime lifetime) {}

  @override
  void dispose() {
    _lifetimes.terminate();
    super.dispose();
  }
}

extension ChangeNotifierLifetimes on ChangeNotifier {
  void trackListener(Lifetime lifetime, void Function() listener) {
    addListener(listener);
    lifetime.add(() {
      removeListener(listener);
    });
  }
}
