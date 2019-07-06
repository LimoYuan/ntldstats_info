import 'package:html/parser.dart' as parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:ntldstats_info/src/logs.dart';

Map<String, String> getUrl = {
    "Registrar": "https://ntldstats.com/registrar",
    "Alibaba": "https://ntldstats.com/registrar/1599-Alibaba-Cloud-Computing-Ltd-dba-HiChina-wwwnetcn",
    "Alibaba_Singapore": "https://ntldstats.com/registrar/3775-ALIBABACOM-SINGAPORE-ECOMMERCE-PRIVATE-LIMITED",
    "Chengdu_West": "https://ntldstats.com/registrar/1556-Chengdu-West-Dimension-Digital-Technology-Co-Ltd",
    "West263": "https://ntldstats.com/registrar/1915-West263-International-Limited",
    "Name_Cheap": "https://ntldstats.com/registrar/1068-NameCheap-Inc",
    "GoDaddy": "https://ntldstats.com/registrar/146-GoDaddycom-LLC"
};

Document getDom(http.Response response) {
    Document document = parse.parse(response.body);
    return document;
}

Element getElement(Document document) {
    Element element = document.querySelector("tbody");
    if(element != null) {
        return element;
    }else {
        ErrorLogs("Functions: getElements(), element is null.");
    }
}