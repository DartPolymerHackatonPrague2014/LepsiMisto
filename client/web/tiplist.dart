import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';

/**
 * A Polymer element to print a list of Tips.
 */
@CustomTag('tip-list')
class TipList extends PolymerElement {
  @published num latitude = 50;
  @published num longitude = 14;
  @observable List<Map> tips = toObservable([]);

  TipList.created() : super.created() {
    loadTips();
  }

  void loadTips() {    
    // call the web server asynchronously
    var request = HttpRequest.getString(getListUrl()).then(onTipListLoaded);
  }
  
  void onTipListLoaded(String responseText) {
    Map parsedJson = JSON.decode(responseText);
    List announcements = parsedJson["announcements"];
    for (var announcement in announcements) {
      loadTipDetail(announcement['id']);
    }
  }
  
  void loadTipDetail(int id) {
    // call the web server asynchronously
    var request = HttpRequest.getString(getDetailUrl(id)).then(onDetailLoaded);
  }
 
  void onDetailLoaded(String responseText) {
    Map parsedJson = JSON.decode(responseText);
    Map announcement = parsedJson["announcement"];
    
    // Set default photo
    setTipPhotoUrl(announcement);
    
    // We run against beta
    announcement['url'] = fixBrokenTipUrl(announcement['url']);
    
    // Format datetime to human readable format
    announcement['created_formatted'] = formatDate(announcement['created']);
 
    insertNewAnnouncement(announcement);
  }
  
  void insertNewAnnouncement(Map announcement) {
    tips.add(announcement);
    tips.sort((Map a, Map b) => -a['created'].compareTo(b['created']));
  }
  
  String getListUrl() {
    // We can't at the moment, due to some-origin-policy. Server does not support CORS.
    //var url = "http://beta-api.lepsimisto.cz/v1/announcement?page=1&lat=" + latitude.toString() + "&lon=" + longitude.toString() + "&announcement_kind=3";
    
    // Use local demo data
    //var url = "json/tips.json";
    
    // Use proxy
    var url = "http://localhost:8081" + "/tips";
    
    return url;
  }
  
  String getDetailUrl(int id) {
     // We can't at the moment, due to some-origin-policy. Server does not support CORS.
     //var url = "http://beta-api.lepsimisto.cz/v1/announcement/" + id.toString();
     
     // Use local demo data
     //var url = "json/tip-" + id.toString() + ".json";
     
     // Use proxy
     var url = "http://localhost:8081" + "/tips/" + id.toString();
     
     return url;
  }
  
  // Sets tip photo or default, is tip does not have any
  void setTipPhotoUrl(Map announcement) {
    if (announcement['photos'].length > 0) {
         announcement['photo'] = announcement['photos'][0]['urls'][0] + "/w100h100";
       } else {
         announcement['photo'] = 'http://beta-www.lepsimisto.cz/Content/images/avatar_small.png';
       }
  }
  
  // Formats unix timestamp to human readable form 
  String formatDate(int timestamp) {
    var datetime = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return new DateFormat('dd.MM.yyyy').format(datetime);
  }
  
  // Fixes broken tip url, we run against Beta
  String fixBrokenTipUrl(String url) {
    return url.replaceFirst("http://www-lepsimisto-cz.azurewebsites.net", "http://beta-www.lepsimisto.cz");
  }
}
