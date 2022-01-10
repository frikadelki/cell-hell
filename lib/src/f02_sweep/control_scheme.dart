enum ControlScheme {
  PrimaryOpens,
  PrimaryFlags,
}

extension ControlSchemeExt on ControlScheme {
  void executePrimary({
    required void Function() open,
    required void Function() flag,
  }) {
    switch (this) {
      case ControlScheme.PrimaryOpens:
        open();
        return;

      case ControlScheme.PrimaryFlags:
        flag();
        return;
    }
  }

  void executeSecondary({
    required void Function() open,
    required void Function() flag,
  }) {
    switch (this) {
      case ControlScheme.PrimaryOpens:
        flag();
        return;

      case ControlScheme.PrimaryFlags:
        open();
        return;
    }
  }
}
