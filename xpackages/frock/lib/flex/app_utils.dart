import 'package:flutter/widgets.dart';
import 'package:frock/runtime/frock_runtime.dart';

class AppOnResumeObserver with WidgetsBindingObserver {
  final void Function() _onResume;

  AppOnResumeObserver.observe(Lifetime lifetime, this._onResume) {
    final binding = WidgetsBinding.instance;
    if (binding == null) {
      return;
    }
    binding.addObserver(this);
    lifetime.add(() {
      binding.removeObserver(this);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.resumed == state) {
      _onResume();
    }
  }
}
