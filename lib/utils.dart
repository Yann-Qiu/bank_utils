import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Utils {
  static bool isSimilar(double num1, double num2) {
    return (num1 - num2).abs() < 0.1;
  }

  static void outputPrint(List<List<dynamic>> combinations, bool withSale, File outputFile) {
    final el = combinations[0];
    final file = outputFile;
    file.writeAsStringSync('| 可以由数组中的数相加得到，这几个数是: \n|\n', mode: FileMode.append);
    String content = '';
    for (var element in el) {
      content += '| No.${element['index'] + 1} - ${element['value']} ${withSale ? '* 0.994': ''}\n';
    }
    file.writeAsStringSync('$content|\n', mode: FileMode.append);
  }

  static bool findSum(List<dynamic> numbers, double target, File file,{bool withSale = false}) {
    List<List<dynamic>> combinations = [];
    
    void backtrack(int index, double sum, List<dynamic> combination) {
      // 是否相等， 相等的话推入结果数组
      if (isSimilar(sum, target)) {
        combinations.add(combination);
        return;
      }
      // 已经大于目标值或越界，直接返回
      if (sum > target || index == numbers.length) {
        return;
      }
      for (int i = index; i < numbers.length; i++) {
        // 超过三项直接剪枝，不考虑
        if (combination.length >= 3) {
          return;
        }
        backtrack(i + 1, sum + numbers[i]['value'], [...combination, numbers[i]]);
      }
    }
    // 开始回溯
    backtrack(0, 0, []);
    // 结果数组大于0才证明有找到
    if (combinations.isNotEmpty) {
      combinations.sort((a, b) => a.length - b.length);
      outputPrint(combinations, withSale, file);
      return true;
    } else {
      return false;
    }
  }

  static String buildPath(List<String> paths) {
    return path.joinAll(paths);
  }

  static Future<String> handle(List<double> input, List<double> output) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String outputFileName = buildPath([appDocumentsDir.path, '${DateTime.now().toString().replaceAll(RegExp(' '), '_')}.txt']);
    File outputFile = File(outputFileName);
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync('第一列总和: ${input.reduce((value, element) => value + element)}\n', mode: FileMode.append);
    outputFile.writeAsStringSync('第一列总和: ${output.reduce((value, element) => value + element)}\n\n', mode: FileMode.append);
    //先从右边的原价找， 找不到的话尝试从 右边原价/0.994 找
    List<List<double>> newOutput = output.map((el) { 
      return [double.parse(el.toString()), double.parse((el / 0.994).toStringAsFixed(2))];
    }).toList();
    for (int index = 0; index < newOutput.length; index++ ) {
      List<double> ele = newOutput[index];
      final first = ele[0];
      final second = ele[1];
      outputFile.writeAsStringSync('|--------------------------------------\n', mode: FileMode.append);
      outputFile.writeAsStringSync('| 右边的第${index + 1}个数字: $first\n', mode: FileMode.append);
      final flag1 = findSum((() {
        List<Map<String, dynamic>> ret = [];
        for (int i = 0; i < input.length; i++ ) {
          ret.add({
            "value": input[i],
            "index": i
          });
        }
        return ret;
      })(), first, outputFile,withSale: false);
      if (flag1) {
        continue;
      }
      final flag2 = findSum((() {
        List<Map<String, dynamic>> ret = [];
        for (int i = 0; i < input.length; i++ ) {
          ret.add({
            "value": input[i],
            "index": i
          });
        }
        return ret;
      })(), second, outputFile,withSale: true);
      if (flag2) {
        continue;
      }
      outputFile.writeAsStringSync('右边的第${index + 1}个数字: $first 找不到!!!!!\n', mode: FileMode.append);
      outputFile.writeAsStringSync('|—--------------------------------------\n', mode: FileMode.append);
    }
    return outputFileName;
  }
}