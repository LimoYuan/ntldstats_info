import 'package:ntldstats_info/ntldstats_info.dart';
import 'package:ntldstats_info/src/logs.dart';
import 'utils/get_all_datas.dart';
import 'utils/get_company_info.dart';
import 'utils/get_domain_ltd_location.dart';
import 'utils/get_dom.dart';
import 'utils/public_function.dart';
import 'package:html/dom.dart';
import 'dart:io';
import 'utils/update_sheets.dart';

final Map<String, dynamic> _config = Get_Config();

Future App() async {
    // create file obj
    File _file = File(_config["spreadsheet_path"]);
    if(!await _file.exists()) {
        ErrorLogs("Function: updateSheets(), Path: ${_config["spreadsheet_path"]} is not found. ExitCode: 102.");
    }
    bool _check = List<String>.from(_config["urls"]).length - 1 == List<String>.from(_config["company_name"]).length && List<String>.from(_config["urls"]).length - 1 == List<String>.from(_config["company_ele"]).length;
    if(!_check){
        ErrorLogs("Function: App(); request_url, company_name, company_ele length not equal. ExitCode: 100.");
        exit(100);
    }
    // 获取所有url的对应的Elements
    List<Element> _allElements = await getElements(_config["urls"]);
    // 获取所有需要查询的公司对应element位置
    List<Element> _companyNameLocationLists = getCompanyInfo(_allElements[0], List<String>.from(_config["company_ele"]));
    // 获取每个公司所有需要查询的域名对应element位置
    List<Element> _companyElements = _allElements;
    _companyElements.removeAt(0);
    List<List> _allCompanyDomainLtdElementsLocation = getCompanyDomainLtdLocation(_companyElements);
    List<List<String>> _allData = getAllData(_companyNameLocationLists, _allCompanyDomainLtdElementsLocation);
    // 写入数据
    updateSheets(_file, _allData);
}



