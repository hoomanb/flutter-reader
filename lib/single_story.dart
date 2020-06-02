import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_state.dart';

class SingleStory extends StatefulWidget {
  SingleStory({Key key, this.link, this.title, this.content}) : super(key: key);

  final String title;
  final String link;
  final String content;

  @override
  _SingleStoryState createState() => new _SingleStoryState();
}

class _SingleStoryState extends State<SingleStory> {

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
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: WebView(
                  initialUrl: widget.content.length > 0
                    ? Uri.dataFromString(
                      '<body style="margin: 0; padding: 0">'
                        + widget.content
                      + '</body>',
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'),
                    ).toString()
                    : widget.link,
                  javascriptMode: JavascriptMode.unrestricted,
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith('http')) {
                      launch(request.url);
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              ),
            ),
            RaisedButton(
              child: const Text(
                'View in Browser', 
                style: TextStyle(fontSize: 20)),
              onPressed: () {
              launch(widget.link);
            },)
          ],
        ),
      ),
    );
  }

}
