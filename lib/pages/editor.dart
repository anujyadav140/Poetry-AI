import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/services/ai/poetry_tools.dart';
import 'package:rive/rive.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:english_words/english_words.dart';

class PoetryEditor extends StatefulWidget {
  final int poemIndex;
  final Color editorAppbarColor;
  final Color editorFontColor;
  final Color editorPrimaryColor;
  const PoetryEditor({
    super.key,
    required this.poemIndex,
    required this.editorAppbarColor,
    required this.editorFontColor,
    required this.editorPrimaryColor,
  });

  @override
  State<PoetryEditor> createState() => _PoetryEditorState();
}

class _PoetryEditorState extends State<PoetryEditor> {
  final isOpenDial = ValueNotifier(false);
  final poemListBox = Hive.box('myPoemBox');
  final poemListIndexBox = Hive.box('myPoemListIndexBox');
  quill.QuillController controller = quill.QuillController(
    document: quill.Document(),
    keepStyleOnNewLine: true,
    selection: const TextSelection.collapsed(offset: 0),
  );
  bool _isRhymeLines = false;
  // bool _isKeyboardVisible = false;
  bool _isInfoClicked = false;
  // late StreamSubscription<bool> keyboardSubscription;
  late String poemTitle = "";
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  final List<dynamic> _googleFonts = [
    ["ebGaramond", GoogleFonts.ebGaramond().fontFamily!],
    ["monofett", GoogleFonts.monofett().fontFamily!],
    ["k2d", GoogleFonts.k2d().fontFamily!],
    ["oswald", GoogleFonts.oswald().fontFamily!],
    ["zhiMangXing", GoogleFonts.zhiMangXing().fontFamily!],
    ["zenTokyoZoo", GoogleFonts.zenTokyoZoo().fontFamily!],
  ];

  final List<dynamic> _aiTools = [
    [1, "images/rhyme.png", "Rhyme Selected Lines", "Placeholder text"],
    [2, "images/rhyme.png", "Rhyme Whole Poem", "Placeholder text"],
    [3, "images/meter.png", "Metre", "Placeholder text"],
    [
      4,
      "images/rhyme.png",
      "Rhyme Scheme Pattern",
      "Find the rhyming scheme pattern for the whole poem"
    ],
    [
      5,
      "images/poetry.png",
      "Generate Few Lines For Inspiration",
      "Placeholder text"
    ],
    [6, "images/dante.png", "Get Inspired", "Placeholder text"],
    [7, "images/lines.png", "Generate Theme Ideas", "Placeholder text"],
    [8, "images/book.png", "What To Write About Next?", "Placeholder text"],
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    bool _isFirstFocus = true;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isFirstFocus) {
        _scrollToCursor();
        _isFirstFocus = false;
      }
    });

    print(poemListBox.get(widget.poemIndex));

    // // poemForm = poemData['form'] as String;
    // var keyboardVisibilityController = KeyboardVisibilityController();
    // print(
    //     'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // // Subscribe
    // keyboardSubscription =
    //     keyboardVisibilityController.onChange.listen((bool visible) {
    //   print('Keyboard visibility update. Is visible: $visible');
    //   setState(() {
    //     _isKeyboardVisible = visible;
    //   });
    // });
  }

  void _scrollToCursor() {
    final cursorOffset = controller.selection.baseOffset;
    const lineHeight =
        26; // You can adjust this value based on your font size and line height
    final scrollToOffset = cursorOffset * lineHeight;

    _scrollController.animateTo(
      scrollToOffset.toDouble(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    _scrollController.dispose();
    // keyboardSubscription.cancel();
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
    return WillPopScope(
      onWillPop: () async {
        if (isOpenDial.value) {
          //close speed dial
          isOpenDial.value = false;

          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
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
            style: GoogleFonts.ebGaramond(
              textStyle: TextStyle(
                color: widget.editorFontColor,
                letterSpacing: .5,
                fontSize: 18,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: widget.editorFontColor,
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
                  showToast("Poem Saved!");
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
            Expanded(
              child: quill.QuillEditor(
                placeholder: "Write your poetry here ...",
                controller: controller,
                focusNode: _focusNode,
                autoFocus: true,
                scrollController: _scrollController,
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
                readOnly: false,
                expands: true,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ]),
        ),
        floatingActionButton: Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
          child: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            foregroundColor: widget.editorFontColor,
            backgroundColor: widget.editorAppbarColor,
            overlayColor: widget.editorAppbarColor,
            overlayOpacity: 0.4,
            spacing: 9,
            spaceBetweenChildren: 9,
            closeManually: false,
            direction: SpeedDialDirection.down,
            openCloseDial: isOpenDial,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.mail),
                label: 'AI Poetry Tool',
                labelStyle: GoogleFonts.ebGaramond(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    letterSpacing: .5,
                    fontSize: 15,
                  ),
                ),
                backgroundColor: widget.editorAppbarColor,
                onTap: () => showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Card(
                          shadowColor: Colors.white,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    height: 5,
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(2.5),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 20, 10, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isInfoClicked
                                          ? 'Information:'
                                          : 'AI Tools:',
                                      style: GoogleFonts.ebGaramond(
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .5,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isInfoClicked = !_isInfoClicked;
                                        });
                                      },
                                      child: Icon(
                                        _isInfoClicked
                                            ? Icons.arrow_back
                                            : Icons.info_outline,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: Colors.grey,
                              ),
                              _isInfoClicked
                                  ? const InfoPage()
                                  : AiToolsList(
                                      aiTools: _aiTools,
                                      controller: controller),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SpeedDialChild(
                child: const Icon(Icons.shutter_speed_outlined),
                label: 'Previous AI Tool Analysis',
                labelStyle: GoogleFonts.ebGaramond(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    letterSpacing: .5,
                    fontSize: 15,
                  ),
                ),
                backgroundColor: widget.editorAppbarColor,
                onTap: () async {
                  // PoetryTools().helloWorld(
                  //     'What is the rhyme for the words SNEED and FEED? Look at the dice coefficient from the tool agent and give your own analysis on it');
                  // final wordToPronunciation =
                  //     await PoetryTools().parseCmuDict();

                  // // Query a specific word (make sure it's transformed to lowercase)
                  // String word = "example";
                  // String? pronunciation =
                  //     wordToPronunciation[word.toLowerCase()];

                  // if (pronunciation != null) {
                  //   print("The pronunciation of '$word' is: $pronunciation");
                  // } else {
                  //   print("Word not found in CMUdict.");
                  // }
                  // Input with multiple words
                  // const String word = "On whose eyes I might approve";
                  // // var syl = syllables(word);
                  // // print(syl);
                  // final stressPattern = PoetryTools()
                  //     .findStressPattern(word, wordToPronunciation);

                  // print("Stress pattern for '$word': $stressPattern");
                  // print(rhyme);
                  // PoetryTools().rhymeAgent();
                },
              ),
            ],
          ),
        ),
        // floatingActionButtonLocation: !_isKeyboardVisible
        //     ? FloatingActionButtonLocation.endFloat
        //     : FloatingActionButtonLocation.endTop,
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: widget.editorAppbarColor,
        textColor: widget.editorFontColor,
        fontSize: 18.0);
  }
}

class AiToolsList extends StatefulWidget {
  const AiToolsList({
    super.key,
    required List aiTools,
    required this.controller,
  }) : _aiTools = aiTools;

  final List _aiTools;
  final quill.QuillController controller;

  @override
  State<AiToolsList> createState() => _AiToolsListState();
}

class _AiToolsListState extends State<AiToolsList> {
  String responseText = "";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget._aiTools.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                String aiToolsSelectTitle = widget._aiTools[index][2];
                print('Clicked on ${widget._aiTools[index][0]}');
                aiToolsSelected(widget._aiTools[index][0], widget.controller)
                    .then((response) {
                  print(response);
                  setState(() {
                    responseText = response;
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      builder: (context) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              color: Colors
                                  .white, // You can change this color as needed
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      height: 5,
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(2.5),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 20, 10, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        aiToolsSelectTitle,
                                        style: GoogleFonts.ebGaramond(
                                          textStyle: const TextStyle(
                                            color: Colors.black,
                                            letterSpacing: .5,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Colors.grey,
                                ),
                                Center(
                                  child: Text(
                                    responseText,
                                    style: GoogleFonts.ebGaramond(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        letterSpacing: .5,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
                });
                // Navigator.of(context).pop();
              },
              splashColor: Colors.grey,
              highlightColor: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset(widget._aiTools[index][1]),
                    ),
                    title: Text(
                      widget._aiTools[index][2],
                      style: GoogleFonts.ebGaramond(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          letterSpacing: .5,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      widget._aiTools[index][3],
                      style: GoogleFonts.ebGaramond(
                        textStyle: const TextStyle(
                          color: Colors.black,
                          letterSpacing: .5,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  if (index != widget._aiTools.length - 1)
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
    );
  }

  Future<String> aiToolsSelected(
      int userChoice, quill.QuillController controller) async {
    AiToolsHandler aiToolsHandler = AiToolsHandler();
    switch (userChoice) {
      case 1:
        aiToolsHandler.rhymeSelectedLines();
        return "";
      case 2:
        aiToolsHandler.rhymeWholePoem();
        return "";
      case 3:
        aiToolsHandler.metreHighlighter();
        return "";
      case 4:
        return await aiToolsHandler.rhymeSchemePattern(controller);
      case 5:
        aiToolsHandler.generateFewLinesForInspiration();
        return "";
      case 6:
        aiToolsHandler.poemInspiration();
        return "";
      default:
        print('Invalid choice.');
        return "";
    }
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Write the info to help user here:");
  }
}

class AiToolsHandler {
  Future<String> rhymeSchemePattern(quill.QuillController controller) async {
    print('Executing RhymeSchemePattern...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response = await PoetryTools().rhymeSchemePatternFinder(plainText);
    return response;
  }

  Future<void> metreHighlighter() async {
    print('Executing MetreHighlighter...');
    // Your implementation for MetreHighlighter here
  }

  Future<void> poemInspiration() async {
    print('Executing PoemInspiration...');
    // Your implementation for PoemInspiration here
  }

  Future<void> rhymeSelectedLines() async {
    print('Executing RhymeSelectedLines...');
    // Your implementation for RhymeSelectedLines here
  }

  Future<void> rhymeWholePoem() async {
    print('Executing RhymeWholePoem...');
    // Your implementation for RhymeWholePoem here
  }

  Future<void> generateFewLinesForInspiration() async {
    print('Executing GenerateFewLinesForInspiration...');
    // Your implementation for GenerateFewLinesForInspiration here
  }
}
