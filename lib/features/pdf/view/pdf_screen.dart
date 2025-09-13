import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class SpaPdfLocalScreen extends StatefulWidget {
  @override
  _SpaPdfLocalScreenState createState() => _SpaPdfLocalScreenState();
}

class _SpaPdfLocalScreenState extends State<SpaPdfLocalScreen> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    _copyPdfToLocal().then((filePath) {
      setState(() {
        localPath = filePath;
      });
    });
  }

  Future<String> _copyPdfToLocal() async {
    final ByteData data = await rootBundle.load("assets/pdf/catalogue_spa.pdf");
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File("${dir.path}/catalogue_spa.pdf");
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Catalogue Spa")),
      body: localPath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(filePath: localPath!),
    );
  }
}
