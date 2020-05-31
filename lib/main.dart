import 'package:flutter/material.dart';

import 'feed_list.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Reader',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FeedList(title: 'Reader Home Page'),
    );
  }
}
