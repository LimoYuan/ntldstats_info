import 'package:ntldstats_info/ntldstats_info.dart';
import 'package:ntldstats_info/src/logs.dart';
import 'public_function.dart';
import 'package:html/dom.dart';
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

final String dateTime = "${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()}";
final String sheetPath = "/home/aeno/Documents/ntldstats_get_data.xlsx";

Future App() async {
    // create file obj
    File file = File.fromUri(Uri.parse(sheetPath));
    if(!await file.exists()) {
        ErrorLogs("Function: updateSheets(), Path: $sheetPath is not found.");
        throw FormatException("Path: $sheetPath is not found.");
    }
    // get all request pages to Elements
    List<Element> allElements = await getElements();
    // get company Element
    Element companyAlibabaElement          = getCompanyInfo(allElements[0])["Company_Alibaba"];
    Element companyWestElement             = getCompanyInfo(allElements[0])["Company_West"];
    Element companyAlibabaSingaporeElement = getCompanyInfo(allElements[0])["Company_Alibaba_Singapore"];
    Element companyWest263Element          = getCompanyInfo(allElements[0])["Company_West263"];
    Element companyNameCheapElement        = getCompanyInfo(allElements[0])["Company_NameCheap"];
    Element companyGoDaddyElement          = getCompanyInfo(allElements[0])["Company_GoDaddy"];
    // get company domain ltd Element
    Map<String, Element> getAlibabaLtdElement          = getCompanyDomainLtdData(allElements[1]);
    Map<String, Element> getChengdu_WestLtdElement     = getCompanyDomainLtdData(allElements[3]);
    Map<String, Element> getAlibabaSingaporeLtdElement = getCompanyDomainLtdData(allElements[2]);
    Map<String, Element> getWest263LtdElement          = getCompanyDomainLtdData(allElements[4]);
    Map<String, Element> getNameCheapLtdElement        = getCompanyDomainLtdData(allElements[5]);
    Map<String, Element> getGoDaddyLtdElement          = getCompanyDomainLtdData(allElements[6]);
    // get data
    List<String> alibaba_datas          = getData("AlibabaCloudComputingLtd(HiChina)", companyAlibabaElement, getAlibabaLtdElement);
    List<String> west_datas             = getData("Chengduwest", companyWestElement, getChengdu_WestLtdElement);
    List<String> alibabaSingapore_datas = getData("AlibabaSingapore", companyAlibabaSingaporeElement, getAlibabaSingaporeLtdElement);
    List<String> west263_datas          = getData("West263", companyWest263Element, getWest263LtdElement);
    List<String> nameCheap_datas        = getData("NameCheap, Inc.", companyNameCheapElement, getNameCheapLtdElement);
    List<String> goDaddy_datas          = getData("GoDaddy", companyGoDaddyElement, getGoDaddyLtdElement);
    // add data list
    List<List> allData = List();
    allData.add(alibaba_datas);
    allData.add(west_datas);
    allData.add(alibabaSingapore_datas);
    allData.add(west263_datas);
    allData.add(nameCheap_datas);
    allData.add(goDaddy_datas);
    // update sheet
    updateSheets(file, allData);
}

// return List<Element>      --> tbody for Element
// [0]: Registrar            --> tbody --> tr --> td[1]: company, td[2]: total, td[3]: grow
// [1]: Alibaba              --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
// [2]: Alibaba_Singapore    --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
// [3]: Chengdu_West         --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
// [4]: West263              --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
// [5]: Name_Cheap           --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
// [6]: GoDaddy              --> tbody --> tr --> td[2]: ltd, td[3]: total, td[4]: grow
Future getElements() async {
    List<Element> getElements = List();
    try {
        getElements.add(
            getElement(getDom(await getResponse(getUrl["Registrar"]))));
        logs("Request Registrar page successful.");
        getElements.add(
            getElement(getDom(await getResponse(getUrl["Alibaba"]))));
        logs("Request Alibaba page successful.");
        getElements.add(
            getElement(getDom(await getResponse(getUrl["Alibaba_Singapore"]))));
        logs("Request Alibaba_Singapore page successful.");
        getElements.add(
            getElement(getDom(await getResponse(getUrl["Chengdu_West"]))));
        logs("Request Chengdu_West page successful.");
        getElements.add(
            getElement(getDom(await getResponse(getUrl["West263"]))));
        logs("Request West263 page successful.");
        getElements.add(
            getElement(getDom(await getResponse(getUrl["Name_Cheap"]))));
        logs("Request Name_Cheap page successful.");
        getElements.add(
            getElement(getDom(await getResponse(getUrl["GoDaddy"]))));
        logs("Request GoDaddy page successful.");
    } catch (e) {
        ErrorLogs("May be west263 link request failed.");
    }
    if (getElements.length >= 7) {
        return getElements;
    }else {
        ErrorLogs("Functions: getDocuments(), Documents length is Error, Length for now: ${getElements.length}, May be west263 link request failed.");
    }
}

// return Map<String, Element>
// key: Company_Alibaba           value: Element
// key: Company_NameCheap         value: Element
// key: Company_GoDaddy           value: Element
// key: Company_West              value: Element
// key: Company_Alibaba_Singapore value: Element
// key: Company_West263           value: Element
Map<String, Element> getCompanyInfo(Element element) {
    Map<String, Element> company_tr = Map();
    List<Element> tbody_trs = element.querySelectorAll("tr");
    // remove Ads
    tbody_trs.removeAt(10);
    for(var item_tr = 0; item_tr < tbody_trs.length; item_tr++) {
        String tr_company = tbody_trs[item_tr].querySelectorAll("td")[1].text.toString();
        switch(tr_company) {
            case "Alibaba Cloud Computing Ltd. (HiChina / www.net.cn, Alibaba Group Holding Ltd.) " :
                logs("Alibaba company. The <tr> location: $item_tr");
                company_tr["Company_Alibaba"] = tbody_trs[item_tr];
                break;
            case "NameCheap, Inc. " :
                logs("NameCheap company. The <tr> location: $item_tr");
                company_tr["Company_NameCheap"] = tbody_trs[item_tr];
                break;
            case "GoDaddy.com, LLC (GoDaddy Group) " :
                logs("GoDaddy company. The <tr> location: $item_tr");
                company_tr["Company_GoDaddy"] = tbody_trs[item_tr];
                break;
            case "Chengdu West Dimension Digital Technology Co., Ltd. (www.west.cn) " :
                logs("Chengdu West company. The <tr> location: $item_tr");
                company_tr["Company_West"] = tbody_trs[item_tr];
                break;
            case "ALIBABA.COM SINGAPORE E-COMMERCE PRIVATE LIMITED (Alibaba Group Holding Ltd.) " :
                logs("Alibaba Singapore company. The <tr> location: $item_tr");
                company_tr["Company_Alibaba_Singapore"] = tbody_trs[item_tr];
                break;
            case "West263 International Limited " :
                logs("West263 company. The <tr> location: $item_tr");
                company_tr["Company_West263"] = tbody_trs[item_tr];
                break;
            default:
            // ErrorLogs("Function: getCompanyInfo(), Not found we needs company info for the element. $item_tr");
                0;
                break;
        }
    }
    return company_tr;
}

// Return Map<String, Element>
Map<String, Element> getCompanyDomainLtdData(Element element) {
    // Need: .top .xyz .club .site .loan .online .vip .fun .wang .men .app .date
    // Need: .tech .win .ltd .work .website .cloud .bid .shop .store .ink .xin .icu
    List<Element> ltd_elements = element.querySelectorAll("tr");
    Map<String, Element> domainElement = Map();
    // remove Ads.
    ltd_elements.removeAt(10);
    print(ltd_elements.length);

    for (var ltd_tr = 0; ltd_tr < ltd_elements.length; ltd_tr++) {
        String ltd_Name = ltd_elements[ltd_tr].querySelectorAll("td")[2].text.trim().toString();
        // print(ltd_Name);
        switch (ltd_Name) {
            case ".top":
                logs("Found ltd .top; location: ${ltd_tr}");
                domainElement["top"] = ltd_elements[ltd_tr];
                break;
            case ".xyz":
                logs("Found ltd .xyz; location: ${ltd_tr}");
                domainElement["xyz"] = ltd_elements[ltd_tr];
                break;
            case ".club":
                logs("Found ltd .club; location: ${ltd_tr}");
                domainElement["club"] = ltd_elements[ltd_tr];
                break;
            case ".site":
                logs("Found ltd .site; location: ${ltd_tr}");
                domainElement["site"] = ltd_elements[ltd_tr];
                break;
            case ".loan":
                logs("Found ltd .loan; location: ${ltd_tr}");
                domainElement["loan"] = ltd_elements[ltd_tr];
                break;
            case ".online":
                logs("Found ltd .online; location: ${ltd_tr}");
                domainElement["online"] = ltd_elements[ltd_tr];
                break;
            case ".vip":
                logs("Found ltd .vip; location: ${ltd_tr}");
                domainElement["vip"] = ltd_elements[ltd_tr];
                break;
            case ".fun":
                logs("Found ltd .fun; location: ${ltd_tr}");
                domainElement["fun"] = ltd_elements[ltd_tr];
                break;
            case ".wang":
                logs("Found ltd .wang; location: ${ltd_tr}");
                domainElement["wang"] = ltd_elements[ltd_tr];
                break;
            case ".men":
                logs("Found ltd .men; location: ${ltd_tr}");
                domainElement["men"] = ltd_elements[ltd_tr];
                break;
            case ".app":
                logs("Found ltd .app; location: ${ltd_tr}");
                domainElement["app"] = ltd_elements[ltd_tr];
                break;
            case ".date":
                logs("Found ltd .date; location: ${ltd_tr}");
                domainElement["date"] = ltd_elements[ltd_tr];
                break;
            case ".tech":
                logs("Found ltd .tech; location: ${ltd_tr}");
                domainElement["tech"] = ltd_elements[ltd_tr];
                break;
            case ".win":
                logs("Found ltd .win; location: ${ltd_tr}");
                domainElement["win"] = ltd_elements[ltd_tr];
                break;
            case ".ltd":
                logs("Found ltd .ltd; location: ${ltd_tr}");
                domainElement["ltd"] = ltd_elements[ltd_tr];
                break;
            case ".work":
                logs("Found ltd .work; location: ${ltd_tr}");
                domainElement["work"] = ltd_elements[ltd_tr];
                break;
            case ".website":
                logs("Found ltd .website; location: ${ltd_tr}");
                domainElement["website"] = ltd_elements[ltd_tr];
                break;
            case ".cloud":
                logs("Found ltd .cloud; location: ${ltd_tr}");
                domainElement["cloud"] = ltd_elements[ltd_tr];
                break;
            case ".bid":
                logs("Found ltd .bid; location: ${ltd_tr}");
                domainElement["bid"] = ltd_elements[ltd_tr];
                break;
            case ".shop":
                logs("Found ltd .shop; location: ${ltd_tr}");
                domainElement["shop"] = ltd_elements[ltd_tr];
                break;
            case ".store":
                logs("Found ltd .store; location: ${ltd_tr}");
                domainElement["store"] = ltd_elements[ltd_tr];
                break;
            case ".ink":
                logs("Found ltd .ink; location: ${ltd_tr}");
                domainElement["ink"] = ltd_elements[ltd_tr];
                break;
            case ".xin":
                logs("Found ltd .xin; location: ${ltd_tr}");
                domainElement["xin"] = ltd_elements[ltd_tr];
                break;
            case ".icu":
                logs("Found ltd .icu; location: ${ltd_tr}");
                domainElement["icu"] = ltd_elements[ltd_tr];
                break;
            default:
        }
    }
    return domainElement;
}

// Get data
// Return List<String>
// List<String> Location value
// [0]  : data for date_time,    [1]  : data for company_name,     [3]  : data for domains total,   [4]  : data for subjoin total,
// [5]  : data for subjoin,      [6]  : data for domains subside,  [7]  : data for .top total,      [8]  : data for .xyz total,
// [9]  : data for .club total,  [10] : data for .site total,      [11] : data for .loan total,     [12] : data for .online,
// [13] : data for .vip total,   [14] : data for .fun total,       [15] : data for .wang total,     [16] : data for .men total,
// [17] : data for .app total,   [18] : data for .date total,      [19] : data for .tech total,     [20] : data for .win total,
// [21] : data for .ltd total,   [22] : data for .work total,      [23] : data for .website total,  [24] : data for .cloud total,
// [25] : data for .bid total,   [26] : data for .shop total,      [27] : data for .store total,    [28] : data for .ink total,
// [29] : data for .xin total,   [30] : data for .icu total,
List<String> getData(String companyName, Element company, Map<String, Element> companyElement) {
    List<String> datas = List();
    if (company.querySelectorAll("td").length == 5) {
        datas.add(dateTime);
        datas.add(companyName);
        datas.add(company.querySelectorAll("td")[2].text.trim().toString().replaceAll(RegExp(r','), ""));
        RegExp reg = RegExp("Gain\.\*\">");
        List<String> tmp = reg.stringMatch(company.querySelectorAll("td")[3].outerHtml).trim().toString().replaceAll(RegExp("[a-zA-Z>/,\"]+"), "").trim().toString().replaceFirst(r":", "").split(":");
        if (tmp.length == 2) {
            datas.add("${int.parse(tmp[0].trim().toString()) - int.parse(tmp[1].trim().toString())}");
            datas.add("${int.parse(tmp[0].trim().toString())}");
            datas.add("-${int.parse(tmp[1].trim().toString()).toString()}");
        }else {
            datas.add("No value");
            datas.add("No value");
            datas.add(company.querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), ""));
        }
        companyElement["top"] != null ? datas.add(companyElement["top"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["top"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["xyz"] != null ? datas.add(companyElement["xyz"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["xyz"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["club"] != null ? datas.add(companyElement["club"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["club"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["site"] != null ? datas.add(companyElement["site"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["site"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["loan"] != null ? datas.add(companyElement["loan"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["loan"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["online"] != null ? datas.add(companyElement["online"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["online"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["vip"] != null ? datas.add(companyElement["vip"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["vip"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["fun"] != null ? datas.add(companyElement["fun"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["fun"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["wang"] != null ? datas.add(companyElement["wang"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["wang"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["men"] != null ? datas.add(companyElement["men"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["men"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["app"] != null ? datas.add(companyElement["app"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["app"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["date"] != null ? datas.add(companyElement["date"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["date"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["tech"] != null ? datas.add(companyElement["tech"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["tech"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["win"] != null ? datas.add(companyElement["win"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["win"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["ltd"] != null ? datas.add(companyElement["ltd"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["ltd"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["work"] != null ? datas.add(companyElement["work"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["work"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["website"] != null ? datas.add(companyElement["website"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["website"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["cloud"] != null ? datas.add(companyElement["cloud"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["cloud"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["bid"] != null ? datas.add(companyElement["bid"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["bid"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["shop"] != null ? datas.add(companyElement["shop"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["shop"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["store"] != null ? datas.add(companyElement["store"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["store"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["ink"] != null ? datas.add(companyElement["ink"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["ink"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["xin"] != null ? datas.add(companyElement["xin"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["xin"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
        companyElement["icu"] != null ? datas.add(companyElement["icu"].querySelectorAll("td")[3].text.trim().toString().replaceAll(RegExp(r','), "") + "(" + companyElement["icu"].querySelectorAll("td")[4].text.trim().toString().replaceAll(RegExp(r','), "") + ")") : datas.add("0");
    }
    return datas;
}

// Update Sheets
updateSheets(File file, List<List> allData) {

    var bytes = file.readAsBytesSync();
    var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

    for(int i = 1; i <= allData.length; i++) {
        decoder.insertRow("Sheet1", 1);
        for(int j = 0; j <  allData[i - 1].length; j++) {
            decoder.updateCell('Sheet1', j, 1, allData[allData.length - i][j]);
        }
        logs("${allData[allData.length - i][1]}: Update data is successful.");
    }
    decoder.insertRow("Sheet1", 1);
    decoder.updateCell('Sheet1', 0, 1, "Separate line");
    file.writeAsBytesSync(decoder.encode());
}
