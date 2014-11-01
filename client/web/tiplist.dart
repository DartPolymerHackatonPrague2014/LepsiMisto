import 'package:polymer/polymer.dart';
//import 'package:paper_elements/paper_input.dart';
//import 'package:core_elements/core_input.dart';
import 'package:core_elements/core_toolbar.dart';
import 'package:core_elements/core_header_panel.dart';
import 'package:core_elements/core_toolbar.dart';
import 'package:paper_elements/paper_icon_button.dart';
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
    
    // Set default photo
    if (announcement['photos'].length > 0) {
      announcement['photo'] = announcement['photos'][0]['urls'][0] + "/w100h100";
    } else {
      announcement['photo'] = 'http://beta-www.lepsimisto.cz/Content/images/avatar_small.png';
    }
    
    // correct url - we want to run against beta
    announcement['url'] = announcement['url'].toString().replaceFirst("http://www-lepsimisto-cz.azurewebsites.net", "http://beta-www.lepsimisto.cz");
    
    
    tips.add(announcement);
//    if (tips.length == 0) {
//      tips.add(announcement);
//    } else {
//      for (var i = 0; i < tips.length; i++) {
//        if (tips[i]['created'] > announcement['created']) {
//          tips.insert(i, announcement);
//          break;
//        }
//      }
//    }
  }
}
