import 'package:cell_hell/src/common/features_navigation.dart';
import 'package:cell_hell/src/common/res.dart';
import 'package:cell_hell/src/features.dart';
import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _RootWidget(),
    );
  }
}

class _RootWidget extends StatefulWidget {
  const _RootWidget({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<_RootWidget> with LifetimedState<_RootWidget> {
  final _fItemProperty = ValueStream<FeatureItem>(featuresItems[0]);

  @override
  void initLifetimedState(Lifetime lifetime) {
    lifetime.add(() {
      _fItemProperty.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: _createFeaturesNavigation,
      child: StreamBuilder(
        stream: _fItemProperty,
        builder: (context, _) {
          return _fItemProperty.value.pageBuilder(context);
        },
      ),
    );
  }

  FeaturesNavigation _createFeaturesNavigation(BuildContext context) {
    final items = featuresItems.map((item) {
      return FeatureNavigationItem(item.name, () {
        _fItemProperty.value = item;
      });
    }).toList(growable: false);
    return FeaturesNavigation(items);
  }
}
