import 'package:html/dom.dart';
import 'package:ntldstats_info/ntldstats_info.dart';
import 'public_function.dart';

/// Return List<List>
List<List> getCompanyDomainLtdLocation(List<Element> company_elements) {
    // Need: .top .xyz .club .site .loan .online .vip .fun .wang .men .app .date
    // Need: .tech .win .ltd .work .website .cloud .bid .shop .store .ink .xin .icu ...other
    // 存放所有公司获取到的域名后缀的位置
    List<List> _allCompanyLtdNameLocations = List();
    // 存放每个公司获取到的每个域名后缀位置
    List _allLtdNames = List();
    // 获取所有需要查询的域名后缀
    List<String> _nameList = List<String>.from(Get_Config()["domains_ltd"]);
    // 遍历所有公司域名后缀的element
    for(int company_element = 0; company_element < company_elements.length; company_element++) {
        List<Element> company_domain_ltd_elements = List();
        try {
            // 获取每个公司的全部域名后缀的element
            company_domain_ltd_elements = company_elements[company_element].querySelectorAll("tr");
            // remove Ads.
            company_domain_ltd_elements.removeAt(10);

            if(company_domain_ltd_elements != null && company_domain_ltd_elements.length > 1) {
                // 筛选出需要的域名后缀在当前公司所有域名后缀列表中的位置
                for(int name = 0; name < _nameList.length; name++) {
                    bool cache = false;
                    Element _element;
                    // 遍历每个公司的全部域名后缀element, 找到需要的域名后缀的tr标签位置
                    for(int ltd_location = 0; ltd_location < company_domain_ltd_elements.length; ltd_location++) {
                        // 获取每个tr对应的域名后缀名称
                        String ltd_Name = company_domain_ltd_elements[ltd_location].querySelectorAll("td")[2].text.trim().toString();
                        if(_nameList[name] == ltd_Name) {
                            _element = company_domain_ltd_elements[ltd_location];
                            logs("Found ltd ${_nameList[name]}; total length: ${company_domain_ltd_elements.length}; location: $ltd_location.");
                            cache = true;
                        }
                    }
                    if(!cache) {
                        // 如果当前公司没有此域名的后缀, 则保存0
                        _allLtdNames.add(0);
                        logs("Not found ltd ${_nameList[name]}; total length: ${company_domain_ltd_elements.length}; May be the company not has ltd name ${_nameList[name]}.");
                    }else{
                        // 将获取到的域名后缀位置保存到数组中
                        _allLtdNames.add(_element);
                    }
                }
            }
        } catch (e, s) {
          print(s);
        }
        if(_allLtdNames.length > 1) {
            _allCompanyLtdNameLocations.add(_allLtdNames);
            _allLtdNames=[];
        }
    }
    return _allCompanyLtdNameLocations;
}