import 'dart:io';

import 'package:bank_utils/utils.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '胖丁的工具箱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '胖丁的工具箱'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        title: Text(widget.title, style: const TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade300
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        File file = File(result.files.single.path!);
                        final bytes = file.readAsBytesSync();
                        final excel = Excel.decodeBytes(bytes);
                        final table = excel.tables[excel.tables.keys.first]!;
                        List<double> input = [];
                        List<double> ouput = [];
                        for (int index = 0 ; index < table.rows.length; index++) {
                          List<Data?> element = table.rows[index];
                          if (index == 0) {
                            if (element[0]?.value?.toString().trim() != '企收银未收' || element[2]?.value?.toString().trim() != '银收企未收') {
                              CherryToast.error(title: const Text('数据格式错误，请下载模版后填写')).show(context);
                              return;
                            } else {
                              continue;
                            }
                          }
                          if (element[0]?.value != null && element[0]?.value != '') {
                            double? parsed = double.tryParse(element[0]!.value.toString());
                            if (parsed != null) {
                              input.add(parsed);
                            }
                          }
                          if (element[2]?.value != null && element[2]?.value != '') {
                            double? parsed = double.tryParse(element[2]!.value.toString());
                            if (parsed != null) {
                              ouput.add(parsed);
                            }
                          }
                        }
                        if (input.isEmpty) {
                          CherryToast.error(title: const Text('第一列数据有误，请重新上传')).show(context);
                          return;
                        }
                        if (input.isEmpty) {
                          CherryToast.error(title: const Text('第二列数据有误，请重新上传')).show(context);
                          return;
                        }
                        String name = await Utils.handle(input, ouput);
                        CherryToast.success(title: Text('文件生成在$name')).show(context);
                        OpenFilex.open(name);
                      }
                    },
                    child: const Text('银行余额调节表解析', style: TextStyle(color: Colors.white),)
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.blue.shade600),
                    onPressed: () async {
                      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
                      String outputFileName = Utils.buildPath([appDocumentsDir.path, 'bank_template.xlsx']);
                      if (File(outputFileName).existsSync()) {
                        File(outputFileName).deleteSync();
                      }
                      File(outputFileName).createSync();
                      final templateData = await rootBundle.load('assets/template.xlsx');
      final           bytes = templateData.buffer.asUint8List();
                      File(outputFileName).writeAsBytesSync(bytes);
                      OpenFilex.open(outputFileName);
                    },
                    child: const Text('模版下载')
                  )
                ],
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade300
                    ),
                    onPressed: null,
                    child: const Text('其他表解析')
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.blue.shade600),
                    onPressed: null,
                    child: const Text('模版下载')
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
