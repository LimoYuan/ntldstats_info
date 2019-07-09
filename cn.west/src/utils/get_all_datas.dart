import 'package:html/dom.dart';

import 'public_function.dart';

final String dateTime = "${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()} ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}";
final List<String> _allCompanyName = List<String>.from(Get_Config()["company_name"]);

/// Get data
/// Return List<String>
/// List<String> Location value
/// [0]  : data for date_time,    [1]  : data for company_name,     [3]  : data for domains total,   [4]  : data for subjoin total,
/// [5]  : data for subjoin,      [6]  : data for domains subside,  [7]  : data for .top total,      [8]  : data for .xyz total,
/// [9]  : data for .club total,  [10] : data for .site total,      [11] : data for .loan total,     [12] : data for .online,
/// [13] : data for .vip total,   [14] : data for .fun total,       [15] : data for .wang total,     [16] : data for .men total,
/// [17] : data for .app total,   [18] : data for .date total,      [19] : data for .tech total,     [20] : data for .win total,
/// [21] : data for .ltd total,   [22] : data for .work total,      [23] : data for .website total,  [24] : data for .cloud total,
/// [25] : data for .bid total,   [26] : data for .shop total,      [27] : data for .store total,    [28] : data for .ink total,
/// [29] : data for .xin total,   [30] : data for .icu total,       [..] : other
List<List<String>> getAllData(List<Element> allCompanyElements, List allDomainLtdElements) {
    List<List<String>> _allData_info = List();
    List<String> allData = List();
    // 遍历所有公司数据
    for(int company_data = 0; company_data < allCompanyElements.length; company_data++) {
        RegExp reg = RegExp("Gain\.\*\">");
        List<String> tmp_company = reg.stringMatch(allCompanyElements[company_data].querySelectorAll("td")[3].outerHtml).trim().toString().replaceAll(RegExp("[a-zA-Z>/,\"]+"), "").trim().toString().replaceFirst(r":", "").split(":");
        // 添加时间
        allData.add(dateTime);
        // 添加公司名称
        allData.add(_allCompanyName[company_data]);
        // 添加总的域名注册数量
        allData.add(allCompanyElements[company_data].querySelectorAll("td")[2].text.trim().toString().replaceAll(RegExp(r','), ""));
        if (tmp_company.length == 2) {
            // 添加最近变化情况 总增个数 - 总减个数
            allData.add("${int.parse(tmp_company[0].trim().toString()) - int.parse(tmp_company[1].trim().toString())}");
            // 添加总增量个数
            allData.add("${int.parse(tmp_company[0].trim().toString())}");
            // 添加总减少个数
            allData.add("-${int.parse(tmp_company[1].trim().toString()).toString()}");
        }else {
            allData.add("No value");
            allData.add("No value");
            allData.add(allCompanyElements[company_data].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), ""));
        }

        for(int domain_data = 0; domain_data < allDomainLtdElements[company_data].length; domain_data++) {
            if(allDomainLtdElements[company_data][domain_data] != 0) {
                List<String> tmp_domains = List();
                // 若最近72小时变化状态为0, 则直接赋值为 0
                if((allDomainLtdElements[company_data][domain_data] as Element).querySelectorAll("td")[4].text.toString().trim() == "0"){
                    tmp_domains.add("0");
                    tmp_domains.add("0");
                }else {
                    tmp_domains = reg.stringMatch((allDomainLtdElements[company_data][domain_data] as Element).querySelectorAll("td")[4].outerHtml).trim().toString().replaceAll(RegExp("[a-zA-Z>/,\"]+"), "").trim().toString().replaceFirst(r":", "").split(":");
                }
                // 总个数
                String _all_domains = (allDomainLtdElements[company_data][domain_data] as Element).querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "");
                // 增加个数
                int _add = int.parse(tmp_domains[0].trim().toString());
                // 减少个数
                int _lower = int.parse(tmp_domains[1].trim().toString());
                // 差值
                int _diff = _add - _lower;
                // 添加要查询的域名总体变化情况, 总增加个数 ,总减少个数
                allData.add("总:$_all_domains(差:$_diff, 增:$_add, 减: $_lower)");
            }else {
                // 如果当前注册局没有这个域名, 则添加 0
                allData.add("0");
            }
        }
        // 添加每个公司的总体数据
        _allData_info.add(allData);
        // 清空当前数据, 继续下一次汇总
        allData = [];
    }
    return _allData_info;
}