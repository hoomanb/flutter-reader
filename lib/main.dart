import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:html_unescape/html_unescape.dart';

void main() => runApp(new MyApp());

final String feedUrl = 'https://nationalpost.com/feed/atom/';

Future<AtomFeed> fetchFeed() async {
  final response =
  await http.get(feedUrl);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return AtomFeed.parse(response.body);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Reader Demo',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: new MyHomePage(title: 'Reader Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _refresh() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("Coming soon!"),
          content: new Text("This feature is coming soon."),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    var unescape = new HtmlUnescape();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: FutureBuilder<AtomFeed>(
                future: fetchFeed(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.items.length,
                      itemBuilder: (BuildContext context, int position) {
                        return ListTile(
                          title: Text(
                            unescape.convert(snapshot.data.items[position].title),
                            style: Theme.of(context).textTheme.headline
                          ),
                          subtitle: Text(
                              unescape.convert(snapshot.data.items[position].summary),
                              style: Theme.of(context).textTheme.caption
                          ),
                          contentPadding: EdgeInsetsDirectional.only(
                            start: 10.0,
                            end: 10.0,
                            top: 15.0,
                            bottom: 15.0,
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                }
              ),
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Refresh',
        child: new Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
