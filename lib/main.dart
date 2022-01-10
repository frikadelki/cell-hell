import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/f01_life/life_page.dart';
import 'package:puffy_playground/src/f02_sweep/sweep_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cell Hell',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _RootWidget(),
    );
  }
}

class _FItem {
  final String name;

  final Widget Function(BuildContext context, Widget fDrawer) pageBuilder;

  const _FItem({required this.name, required this.pageBuilder});
}

final _fItems = [
  _FItem(
    name: 'Minesweeper',
    pageBuilder: (context, fDrawer) => SweepPage(fDrawer: fDrawer),
  ),
  _FItem(
    name: 'Conway\'s Life',
    pageBuilder: (context, fDrawer) => LifePage(fDrawer: fDrawer),
  ),
];

class _RootWidget extends StatefulWidget {
  const _RootWidget({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<_RootWidget> with LifetimedState<_RootWidget> {
  final _fItemProperty = ValueStream<_FItem>(_fItems[0]);

  @override
  void initLifetimedState(Lifetime lifetime) {
    lifetime.add(() {
      _fItemProperty.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _fItemProperty,
      builder: (context, _) {
        return _fItemProperty.value.pageBuilder(
          context,
          _FDrawer(itemController: _fItemProperty),
        );
      },
    );
  }
}

class _FDrawer extends StatelessWidget {
  final ValueStream<_FItem> itemController;

  const _FDrawer({
    Key? key,
    required this.itemController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          ..._fItems.map(
            (item) => ListTile(
              title: Text(item.name),
              onTap: () => itemController.value = item,
            ),
          ),
        ],
      ),
    );
  }
}
