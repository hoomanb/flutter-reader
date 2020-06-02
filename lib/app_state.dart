import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart';
import 'package:webfeed/webfeed.dart';
import 'package:html_unescape/html_unescape.dart';

// Update and keep directory data from remote JSON
class AppState extends ChangeNotifier {

  static const String STORAGE_KEY_FEED = 'FeedJson';
  static const String STORAGE_KEY_FEED_TIMESTAMP = 'DirectoryJsonTimestamp';

  static const int FEED_CACHE_TTL = 3 * 60 * 60 * 1000; // (3 hours) Time to keep json locally in milliseconds
  static const String FEED_URL = 'http://rss.cbc.ca/lineup/topstories.xml';
  static const int _JSON_VERSION = 1;

  Map<String, dynamic> _feed = {
    'version': _JSON_VERSION, // In case JSON format changes
    'items': []
  };

  bool _isFetching = false;

  bool get isFetching => _isFetching;

  AppState() {
    loadFeed();
  }

  // Get Feed
  Future<Map<String, dynamic>> getFeed() async {
    if ((_feed["items"] as List).length == 0) {
      loadFeed();
    }
    return _feed;
  }

  // Load
  Future<void> loadFeed() async {
    final prefs = await SharedPreferences.getInstance();

    // No data, load from cache or fetch
    if ( prefs.containsKey(STORAGE_KEY_FEED) && 
        prefs.containsKey(STORAGE_KEY_FEED_TIMESTAMP) ) {

      _feed = json.decode(prefs.getString(STORAGE_KEY_FEED));

      // Reload if expired
      int now = new DateTime.now().millisecondsSinceEpoch;
      if (now - prefs.getInt(STORAGE_KEY_FEED_TIMESTAMP) > FEED_CACHE_TTL) {
        fetchFeed();
      }
    } else {
      // Fetch new data
      fetchFeed();
    }
    notifyListeners();
  }

  // Fetch new data
  Future<void> fetchFeed() async {
    _isFetching = true;
    notifyListeners();

    try {
      // Receive & parse
      final response = await http.get(FEED_URL);
      var unescape = new HtmlUnescape();
      if(response.statusCode == 200) {
        RssFeed _rssFeed = RssFeed.parse(response.body);

        // Parse RSS items into simple unified JSON
        List<Map<String, dynamic>> items = [];
        _rssFeed.items.forEach((rssItem) {
          Map<String, dynamic> newItem = {};

          newItem['title'] = unescape.convert(rssItem.title);

          newItem['link'] = rssItem.link;

          newItem['description'] = rssItem.description;

          // Remove html from description for excerpt
          newItem['excerpt'] = rssItem.description != null ? parse(rssItem.description).documentElement.text.trim() : '...';

          // Add thumbnail if available
          if (rssItem.media.thumbnails.length > 0) {
            newItem['thumbnail'] = rssItem.media.thumbnails[0].url;
          }

          items.add(newItem);

        });     
        _feed['items'] = items;
        _isFetching = false;

        // Now cache locally
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(STORAGE_KEY_FEED, json.encode(_feed));
        prefs.setInt(STORAGE_KEY_FEED_TIMESTAMP, new DateTime.now().millisecondsSinceEpoch);

        notifyListeners();
      }
    } catch(e) {
      print(e);
    }
  }

}
