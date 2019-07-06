// TODO: Put public facing types in this file.
import 'package:http/http.dart' as http;
import 'logs.dart';

final Map<String, String> headers = {
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
  "Accept-Language": "h-CN,zh;q=0.9",
  "Cookie": "cookieconsent_status=dismiss",
  "Host": "ntldstats.com",
  "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
};

Future getResponse(String url) async {
  http.Response response;
  if(url.isNotEmpty) {
    response = await http.get(url, headers: headers);
    if(response.statusCode == 200) {
      return response;
    } else {
      ErrorLogs("Functions: getResponse(), Request statusCode is not 200, StatusCode: ${response.statusCode}");
    }
  } else {
    ErrorLogs("Functions: getResponse(), Request URL is empty.");
  }
}

