import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';

class PoetryEditor extends StatefulWidget {
  const PoetryEditor({super.key});

  @override
  State<PoetryEditor> createState() => _PoetryEditorState();
}

class _PoetryEditorState extends State<PoetryEditor> {
  quill.QuillController controller = quill.QuillController(
    document: quill.Document(),
    keepStyleOnNewLine: true,
    selection: const TextSelection.collapsed(offset: 0),
  );
  final List<String> _googleFonts = [
    GoogleFonts.ebGaramond().fontFamily!,
    GoogleFonts.roboto().fontFamily!,
    GoogleFonts.lato().fontFamily!,
    GoogleFonts.oswald().fontFamily!,
    GoogleFonts.zhiMangXing().fontFamily!,
    GoogleFonts.zenTokyoZoo().fontFamily!,
  ];
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {}

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Editor"), actions: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.back_hand))
      ]),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(children: [
        quill.QuillToolbar.basic(
          controller: controller,
          toolbarIconSize: 15,
          showQuote: false,
          showIndent: false,
          showDividers: false,
          showSubscript: false,
          showSuperscript: false,
          showListBullets: false,
          showListNumbers: false,
          showHeaderStyle: false,
          showListCheck: false,
          showInlineCode: false,
          showSearchButton: false,
          showLink: false,
          showFontSize: true,
          showFontFamily: true,
          fontSizeValues: const {
            'Small': '26',
            'Medium': '32',
            'Large': '38',
          },
          fontFamilyValues: {
            for (var fontFamily in _googleFonts) fontFamily: fontFamily
          },
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: quill.QuillEditor(
                placeholder: "Write your poetry here ...",
                controller: controller,
                focusNode: focusNode,
                scrollController: scrollController,
                scrollable: true,
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                      GoogleFonts.ebGaramond(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: Colors.black),
                      const quill.VerticalSpacing(0, 6),
                      const quill.VerticalSpacing(0, 6),
                      null),
                ),
                padding: const EdgeInsets.all(15.0),
                autoFocus: true,
                readOnly: false,
                expands: true,
                textCapitalization: TextCapitalization.sentences,
              ),
            );
          },
        ),
      ]))),
    );
  }
}
