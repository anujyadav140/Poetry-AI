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
  bool _isRhymeLines = false;
  final List<dynamic> _googleFonts = [
    ["ebGaramond", GoogleFonts.ebGaramond().fontFamily!],
    ["monofett", GoogleFonts.monofett().fontFamily!],
    ["k2d", GoogleFonts.k2d().fontFamily!],
    ["oswald", GoogleFonts.oswald().fontFamily!],
    ["zhiMangXing", GoogleFonts.zhiMangXing().fontFamily!],
    ["zenTokyoZoo", GoogleFonts.zenTokyoZoo().fontFamily!],
  ];

  final List<String> _aiTools = [
    "RHYME SELECTED LINES",
    "RHYME WHOLE POEM",
    "SHOW / FIND THE METER OF THE WHOLE POEM",
    "THE RHYME SCHEME OF THE WHOLE POEM",
    "THE GENERATE FEW LINES (REMAINING LINES) FOR INSPIRATION",
    "INSPIRATION ",
    "THEME GENERATOR",
    "WHAT TO WRITE ABOUT NEXT?"
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

//CURSOR OFFSET RETURNS THE PLAINTEXT FROM CURSOR POSITION
  void _onTextChanged() {
    if (_isRhymeLines) {
      String rhymeLinesInput = getSelectedTextAsPlaintext(controller);
      print('For rhyme lines: $rhymeLinesInput');
    } else {
      String cursorPositionPlaintext = getCursorPositionPlainText(controller);
      print('Plain Text before the cursor: $cursorPositionPlaintext');
    }
  }

  String getCursorPositionPlainText(quill.QuillController controller) {
    final cursorPosition = controller.selection.baseOffset;
    final entirePlainText = controller.document.toPlainText();
    final textBeforeCursor = entirePlainText.substring(0, cursorPosition);
    if (textBeforeCursor.isNotEmpty) {
      return textBeforeCursor;
    }
    return '';
  }

  // Function to get the selected text as plaintext.
  String getSelectedTextAsPlaintext(quill.QuillController controller) {
    final selection = controller.selection;
    final start = selection.start;
    final end = selection.end;

    if (start != null && end != null && start < end) {
      final selectedPlainText =
          controller.document.toPlainText().substring(start, end);
      return selectedPlainText;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Editor"), actions: [
        IconButton(
            onPressed: () {
              print("check!000");
              setState(() {
                _isRhymeLines = !_isRhymeLines;
              });
            },
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
                for (var fontFamily in _googleFonts)
                  fontFamily[0]: fontFamily[1]
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
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (builder) => bottomSheet());
        },
      ),
    );
  }

  Widget bottomSheet() {
    return SizedBox(
        height: 278,
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: const EdgeInsets.all(18.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: _aiTools.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.abc),
                        ),
                        title: Text(
                          _aiTools[index],
                          style: GoogleFonts.ebGaramond(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      if (index != _aiTools.length - 1)
                        const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }
}
