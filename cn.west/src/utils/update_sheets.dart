import 'dart:io';
import 'package:ntldstats_info/src/logs.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

// Update Sheets
updateSheets(File file, List<List<String>> allData) {

    var bytes = file.readAsBytesSync();
    var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
    decoder.insertRow("Sheet1", 1);
    decoder.updateCell('Sheet1', 0, 1, "Separate line");

    for(int i = 1; i <= allData.length; i++) {
        decoder.insertRow("Sheet1", 1);
        for(int j = 0; j <  allData[i - 1].length; j++) {
            decoder.updateCell('Sheet1', j, 1, allData[allData.length - i][j]);
        }
        logs("${allData[allData.length - i][1]}: Update data is successful.");
    }
    file.writeAsBytesSync(decoder.encode());
}