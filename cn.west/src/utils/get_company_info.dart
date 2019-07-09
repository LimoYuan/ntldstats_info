import 'dart:io';

import 'package:html/dom.dart';
import 'package:ntldstats_info/ntldstats_info.dart';

/// return Map<String, Element>
/// key: Company_Alibaba            value: Element
/// key: Company_West               value: Element
/// key: Company_Alibaba_Singapore  value: Element
/// key: Company_West263            value: Element
/// key: Company_NameCheap          value: Element
/// key: Company_GoDaddy            value: Element
List<Element> getCompanyInfo(Element element, List<String> company_name) {
    List<Element> _companyNameLocation = List();
    List<Element> tbody_trs = element.querySelectorAll("tr");
    // remove Ads
    tbody_trs.removeAt(10);
    for(int _name = 0; _name < company_name.length; _name++){
        bool _found = false;
        for(int item_tr = 0; item_tr < tbody_trs.length; item_tr++) {
            String tr_company = tbody_trs[item_tr].querySelectorAll("td")[1].text.toString();
            if(tr_company == company_name[_name]) {
                _companyNameLocation.add(tbody_trs[item_tr]);
                logs("The company name: $tr_company find it; \n    Location: $item_tr");
                _found = true;
                break;
            }
        }
        if(!_found) {
            ErrorLogs("Function: getCompanyInfo(); Not found ${company_name[_name]} for https://ntldstats.com . ExitCode: 103.");
            exit(103);
        }
    }
    return _companyNameLocation;
}