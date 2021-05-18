import 'package:flutter/material.dart';
import 'package:dsi_app/view/word_pair_view.dart';

void main() {
  runApp(DSIApp());
}

class DSIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSI App (BSI UFRPE)',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      initialRoute: HomePage.routeName,
      routes: _buildRoutes(context),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes(BuildContext context) {
    return {
      WordPairUpdatePage.routeName: (context) => WordPairUpdatePage(),
    };
  }
}
