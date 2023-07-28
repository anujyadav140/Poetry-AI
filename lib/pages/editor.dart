import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:rive/rive.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PoetryEditor extends StatefulWidget {
  final int poemIndex;
  final Color editorAppbarColor;
  final Color editorFontColor;
  const PoetryEditor({
    super.key,
    required this.poemIndex,
    required this.editorAppbarColor,
    required this.editorFontColor,
  });

  @override
  State<PoetryEditor> createState() => _PoetryEditorState();
}

class _PoetryEditorState extends State<PoetryEditor> {
  final poemListBox = Hive.box('myPoemBox');
  final poemListIndexBox = Hive.box('myPoemListIndexBox');
  quill.QuillController controller = quill.QuillController(
    document: quill.Document(),
    keepStyleOnNewLine: true,
    selection: const TextSelection.collapsed(offset: 0),
  );
  bool _isRhymeLines = false;
  bool _isKeyboardVisible = false;
  late StreamSubscription<bool> keyboardSubscription;
  late String poemTitle = "";
  final List<dynamic> _googleFonts = [
    ["ebGaramond", GoogleFonts.ebGaramond().fontFamily!],
    ["monofett", GoogleFonts.monofett().fontFamily!],
    ["k2d", GoogleFonts.k2d().fontFamily!],
    ["oswald", GoogleFonts.oswald().fontFamily!],
    ["zhiMangXing", GoogleFonts.zhiMangXing().fontFamily!],
    ["zenTokyoZoo", GoogleFonts.zenTokyoZoo().fontFamily!],
  ];

  final List<dynamic> _aiTools = [
    ["images/rhyme.png", "RHYME SELECTED LINES"],
    ["images/rhyme.png", "RHYME WHOLE POEM"],
    ["images/meter.png", "SHOW / FIND THE METER OF THE WHOLE POEM"],
    ["images/rhyme.png", "THE RHYME SCHEME OF THE WHOLE POEM"],
    [
      "images/poetry.png",
      "THE GENERATE FEW LINES (REMAINING LINES) FOR INSPIRATION"
    ],
    ["images/dante.png", "INSPIRATION"],
    ["images/lines.png", "THEME GENERATOR"],
    ["images/book.png", "WHAT TO WRITE ABOUT NEXT?"]
  ];

  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    poemTitle = poemData['title'] as String;
    String? poetryContent = poemData['poetry'] as String?;
    var myJSON = poetryContent != null ? jsonDecode(poetryContent) : null;
    controller = quill.QuillController(
      document:
          myJSON != null ? quill.Document.fromJson(myJSON) : quill.Document(),
      keepStyleOnNewLine: true,
      selection: const TextSelection.collapsed(offset: 0),
    );

    print(poemListBox.get(widget.poemIndex));

    // poemForm = poemData['form'] as String;
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    print(
        'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      setState(() {
        _isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    keyboardSubscription.cancel();
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
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ));
            },
            icon: const Icon(Icons.arrow_back)),
        title: Text(
          "Editor - $poemTitle",
          style: TextStyle(
            color: widget.editorFontColor,
          ),
        ),
        iconTheme: IconThemeData(
          color: widget.editorFontColor, // Set the custom color here
        ),
        backgroundColor: widget.editorAppbarColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        )),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // setState(() {
                //   _isRhymeLines = !_isRhymeLines;
                // });
                var poemData = poemListBox.getAt(widget.poemIndex)
                    as Map<dynamic, dynamic>;
                poemData['poetry'] =
                    jsonEncode(controller.document.toDelta().toJson());
                poemListBox.putAt(widget.poemIndex, poemData);

                Fluttertoast.showToast(
                    msg: "Poem Saved!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              });
            },
            icon: Icon(
              Icons.save,
              color: widget.editorFontColor,
            ),
          ),
        ],
      ),
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
              color: Colors.grey,
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
      floatingActionButton: Padding(
        padding: !_isKeyboardVisible
            ? const EdgeInsets.only(top: 0)
            : EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: FloatingActionButton(
          backgroundColor: widget.editorAppbarColor,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(_aiTools[0][0]),
          ),
          onPressed: () {
            showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (builder) => bottomSheet());
          },
        ),
      ),
      floatingActionButtonLocation: !_isKeyboardVisible
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endTop,
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: _aiTools.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    print('Clicked on ${_aiTools[index][1]}');
                  },
                  splashColor: widget.editorAppbarColor,
                  highlightColor: Colors.transparent,
                  child: Column(
                    children: [
                      ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(_aiTools[index][0]),
                        ),
                        title: Text(
                          _aiTools[index][1],
                          style: GoogleFonts.ebGaramond(
                            textStyle: TextStyle(
                              color: widget.editorFontColor,
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
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
              color: widget.editorFontColor,
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
