import 'dart:io';
import 'dart:convert';
import 'package:route/server.dart';
import 'package:route/url_pattern.dart';

const port = 8081;

final tipsPattern = new UrlPattern(r'/tips/@(\d+)/(\d+)\/?');
final tipPattern = new UrlPattern(r'/tips/(\d+)\/?');

void main() {
  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
    print("Serving at ${server.address} on port ${server.port}");
      var router = new Router(server)
       ..serve(tipsPattern, method: 'GET').listen(tips)
       ..serve(tipPattern, method: 'GET').listen(tipDetail)
       ..defaultStream.listen(serveNotFound);
    });
}

tips(HttpRequest req) {
  var path = tipsPattern.parse(req.uri.path);
  var latitude = path[0];
  var longitude = path[1];
  var client = new HttpClient();
  client.getUrl(Uri.parse("http://beta-api.lepsimisto.cz/v1/announcement?page=1&page_size=5&lat=${latitude}&lon=${longitude}&announcement_kind=3"))
  .then((clientReq) => clientReq.close())
  .then((HttpClientResponse response) {
    req.response.headers.add("Access-Control-Allow-Origin", "*"); // support CORS
    req.response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
    response.transform(UTF8.decoder).listen((contents) {
      req.response..write(contents)..close();
    });
  });
}

tipDetail(HttpRequest req) {
  var path = tipPattern.parse(req.uri.path);
  var tipId = path[0];
  var client = new HttpClient();
  client.getUrl(Uri.parse("http://beta-api.lepsimisto.cz/v1/announcement/${tipId}"))
  .then((clientReq) => clientReq.close())
  .then((HttpClientResponse response) {
    req.response.headers.add("Access-Control-Allow-Origin", "*"); // support CORS
    req.response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
    response.transform(UTF8.decoder).listen((contents) {  
      req.response..write(contents)..close();
    });
  });
}

// Callback to handle illegal urls.
serveNotFound(req) {
  req.response.statusCode = HttpStatus.NOT_FOUND;
  req.response.write('Not found');
  req.response.close();
}
