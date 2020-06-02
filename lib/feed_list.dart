import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'single_story.dart';
import 'app_state.dart';

class FeedList extends StatefulWidget {
  FeedList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FeedListState createState() => new _FeedListState();
}

class _FeedListState extends State<FeedList> {

  @override
  Widget build(BuildContext context) {
    final AppState appState = Provider.of<AppState>(context, listen: true);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: FutureBuilder<Map<String,dynamic>>(
                future: appState.getFeed(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data['items'].length,
                      itemBuilder: (BuildContext context, int position) {
                        Map<String, dynamic> item = snapshot.data['items'][position];

                        // Add thumbnail if available
                        Widget thumbnail = item.containsKey('thumbnail') ?
                          CachedNetworkImage(
                            imageUrl: item['thumbnail'],
                            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                          ) : null;

                        return Card(
                          child: ListTile(
                            leading: thumbnail,
                            title: Text(
                              item['title'],
                              style: Theme.of(context).textTheme.headline5
                            ),
                            subtitle: Padding(
                              child: Text(
                                item['excerpt'],
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleStory(title: item['title'], link: item['link'], content: item['description']),
                                  ),
                              );
                            },
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
        onPressed: () {
          appState.fetchFeed();
        },
        tooltip: 'Refresh',
        child: new Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
