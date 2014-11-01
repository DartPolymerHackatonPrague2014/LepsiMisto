import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:convert';

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
    //var url = "http://beta-api.lepsimisto.cz/v1/announcement?page=1&lat=" + latitude.toString() + "&lon=" + longitude.toString() + "&announcement_kind=3";
    var url = "json/tips.json";
    
    // call the web server asynchronously
    var request = HttpRequest.getString(url).then(onTipListLoaded);
  }
  
  void loadTipDetail(int id) {
     //var url = "http://beta-api.lepsimisto.cz/v1/announcement?page=1&lat=" + latitude.toString() + "&lon=" + longitude.toString() + "&announcement_kind=3";
     var url = "json/tip-" + id.toString() + ".json";
     
     // call the web server asynchronously
     var request = HttpRequest.getString(url).then(onDetailLoaded);
   }
  
  void onTipListLoaded(String responseText) {
    Map parsedJson = JSON.decode(responseText);
    List announcements = parsedJson["announcements"];
    for (var announcement in announcements) {
      loadTipDetail(announcement['id']);
    }
  }
 
  void onDetailLoaded(String responseText) {
     Map parsedJson = JSON.decode(responseText);
     Map announcement = parsedJson["announcement"];
     tips.add(announcement);
   }
}
