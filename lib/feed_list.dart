import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:webfeed/webfeed.dart';
import 'package:html_unescape/html_unescape.dart';

class FeedList extends StatefulWidget {
  FeedList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FeedListState createState() => new _FeedListState();
}

class _FeedListState extends State<FeedList> {

final String feedUrl = 'http://rss.cbc.ca/lineup/topstories.xml';

  Future<RssFeed> _feed;

  @override
  void initState() {
    _feed = _fetchFeed();
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
              child: FutureBuilder<RssFeed>(
                future: _feed,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.items.length,
                      itemBuilder: (BuildContext context, int position) {
                        // Remove html from description
                        var description = snapshot.data.items[position].description != null ? parse(snapshot.data.items[position].description).documentElement.text : '...';

                        // Add thumbnail if available
                        Widget thumbnail = snapshot.data.items[position].media.thumbnails.length > 0 ?
                          CachedNetworkImage(
                            imageUrl: snapshot.data.items[position].media.thumbnails[0].url,
                            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                          ) : null;

                        return Card(
                          child: ListTile(
                            leading: thumbnail,
                            title: Text(
                              unescape.convert(snapshot.data.items[position].title),
                              style: Theme.of(context).textTheme.headline5
                            ),
                            subtitle: Padding(
                              child: Text(
                                description.trim(),
                                style: Theme.of(context).textTheme.bodyText2
                              ),
                              padding: EdgeInsets.only(top: 10)
                            ),
                            contentPadding: EdgeInsetsDirectional.only(
                              start: 10.0,
                              end: 10.0,
                              top: 15.0,
                              bottom: 15.0,
                            ),
                          )
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("ERROR: ${snapshot.error}");
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

  Future<RssFeed> _fetchFeed() async {
    final response = await http.get(feedUrl);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return RssFeed.parse(response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  void _refresh() async {
    setState(() {
      _feed = _fetchFeed();
    });
  }
}
