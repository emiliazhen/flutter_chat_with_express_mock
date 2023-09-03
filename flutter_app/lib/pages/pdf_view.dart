import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import 'package:flutter_app/components/index.dart';

class PdfViewPage extends StatefulWidget {
  PdfViewPage({Key? key, required this.isJs}) : super(key: key);
  final bool isJs;
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  PdfControllerPinch? pdfPinchController;

  @override
  void initState() {
    super.initState();
    pdfPinchController = PdfControllerPinch(
      document: PdfDocument.openAsset("pdfs/${widget.isJs ? 'js' : 'web'}.pdf"),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(
          context,
          '查看',
        ),
        body: PdfViewPinch(
          controller: pdfPinchController!,
        ));
  }
}
