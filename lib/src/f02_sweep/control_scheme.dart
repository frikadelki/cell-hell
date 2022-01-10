enum ControlScheme {
  primaryOpens,
  primaryFlags,
}

extension ControlSchemeExt on ControlScheme {
  void executePrimary({
    required void Function() open,
    required void Function() flag,
  }) {
    switch (this) {
      case ControlScheme.primaryOpens:
        open();
        return;

      case ControlScheme.primaryFlags:
        flag();
        return;
    }
  }

  void executeSecondary({
    required void Function() open,
    required void Function() flag,
  }) {
    switch (this) {
      case ControlScheme.primaryOpens:
        flag();
        return;

      case ControlScheme.primaryFlags:
        open();
        return;
    }
  }
}
