import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'feed_list.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
        child: MaterialApp(
        title: 'Flutter Reader',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new FeedList(title: AppState.TITLE_FEEDLIST),
      )
    );
  }
}
