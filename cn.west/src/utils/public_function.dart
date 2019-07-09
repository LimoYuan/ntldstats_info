import 'dart:convert';
import 'dart:io';
import 'package:ntldstats_info/ntldstats_info.dart';

final String _configPath = "/home/aeno/Documents/ntldstats_info/assets/config.json";
final Map<String, dynamic> _config = Map();

Map<String, dynamic> Get_Config() {
    final File _file = File(_configPath);
    if(!_file.existsSync()) {
        ErrorLogs("Function: getConfig(); config.json in '$_configPath' is not found.");
        try {
            _file.createSync();
            _file.writeAsStringSync(Base_Config());
            logs("Create config file successful.");
        } catch (e) {
            ErrorLogs("Function: Get_Config(); Create config file failed. ExitCode: 101.");
            exit(101);
        }
    }

    Map<String, dynamic> config = json.decode(_file.readAsStringSync(encoding: utf8));
    _config["spreadsheet_path"] = config["sheet_path"];
    try{
        if(config["request_url"] is List && config["request_url"].length > 1) {
            _config["urls"] = config["request_url"] as List;
        }
        if(config["company_name"] is List && config["company_name"].length > 1) {
            _config["company_name"] = config["company_name"] as List;
        }
        if(config["company_ele"] is List && config["company_ele"].length > 1) {
            _config["company_ele"] = config["company_ele"] as List;
        }
        if(config["domains_ltd"] is List && config["domains_ltd"].length > 1) {
            _config["domains_ltd"] = config["domains_ltd"] as List;
        }
    }catch (e) {
        ErrorLogs("Function: Get_Config(); Json decode has Error.");
    }
    return _config;
}