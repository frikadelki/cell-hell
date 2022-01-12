import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeatureNavigationItem {
  final String name;

  final void Function() navigate;

  FeatureNavigationItem(this.name, this.navigate);
}

class FeaturesNavigation {
  final List<FeatureNavigationItem> items;

  FeaturesNavigation(this.items);

  factory FeaturesNavigation.of(BuildContext context) => Provider.of(context);
}

class FeaturesNavigationDrawer extends StatelessWidget {
  const FeaturesNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigation = FeaturesNavigation.of(context);
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Cell Hell',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ...navigation.items.map(
            (item) => ListTile(
              title: Text(item.name),
              onTap: item.navigate,
            ),
          ),
        ],
      ),
    );
  }
}
