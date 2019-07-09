import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parse;
import 'package:ntldstats_info/ntldstats_info.dart';
import 'package:ntldstats_info/src/logs.dart';
import 'dart:io';

Document _getDocument(http.Response response) {
    Document document = Document();
    try{
        document = parse.parse(response.body);
        return document;
    }catch(e) {
        ErrorLogs("Function: getDocument(); Response body can't parse to Dom for HTML.");
        FormatException("Response body can't parse to Dom for HTML.");
    }
}

/// @param List<String>       --> tbody for Element
/// @return List<Element>
/// [0]: Registrar            --> tbody --> tr --> td[1]: company, td[2]: total, td[3]: grow
/// [1]: Alibaba              --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
/// [2]: Chengdu_West         --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
/// [3]: Alibaba_Singapore    --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
/// [4]: West263              --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
/// [5]: Name_Cheap           --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
/// [6]: GoDaddy              --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
/// [.]: other company        --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
Future<List<Element>> getElements(List urls) async {
    List<Element> _elements = List();
    Element _element;
    for(int i = 0; i < urls.length; i++) {
        try {
          _element = _getDocument(await getResponse(urls[i]).catchError((onError){
              ErrorLogs("Request url: ${urls[i]} \n        is failed. May be the url is unable to connect, Please wait try again.");
          })).querySelector("tbody");
          logs("No.${i + 1}, Url: ${urls[i]} \n    Request successful, Parse tbody is successful.");
        } catch (e) {
          ErrorLogs("Function: getElements(); Requset failed for Pages; querySelector: <tbody> tag failed. ExitCode: 201.");
          exit(201);
        }
        _element != null ? _elements.add(_element) : ErrorLogs("Functions: getElements(), element is null.");
    }
    return _elements;
}

