import 'package:flutter/material.dart';

extension WidgetsListOps on Iterable<Widget> {
  List<Widget> interleave(
    BuildContext context,
    WidgetBuilder separatorBuilder, {
    bool beforeFirst = false,
    bool afterLast = false,
  }) {
    final result = <Widget>[];
    void addSeparator() {
      result.add(separatorBuilder(context));
    }

    if (isEmpty) {
      return result;
    }
    if (beforeFirst) {
      addSeparator();
    }
    final length = this.length;
    for (var index = 0; index < length; index++) {
      result.add(elementAt(index));
      final isLast = index == length - 1;
      if (!isLast) {
        addSeparator();
      }
    }
    if (afterLast) {
      addSeparator();
    }
    return result;
  }
}
