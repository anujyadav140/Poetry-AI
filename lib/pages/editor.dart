import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/api/poetry_ai.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/pages/give_title.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/services/ai/poetry_tools.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:rive/rive.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

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

class _PoetryEditorState extends State<PoetryEditor>
    with TickerProviderStateMixin {
  final isOpenDial = ValueNotifier(false);
  final poemListBox = Hive.box('myPoemBox');
  final poemListIndexBox = Hive.box('myPoemListIndexBox');
  final adsCounterStore = Hive.box('myAdsCounterStore');
  int currentAdsCounter = 1;
  late AnimationController _animationController;
  quill.QuillController controller = quill.QuillController(
    document: quill.Document(),
    keepStyleOnNewLine: true,
    selection: const TextSelection.collapsed(offset: 0),
  );
  bool _isRhymeLines = false;
  bool _isInfoClicked = false;
  bool showBookmarkModal = false;
  bool scrollToBottomOfBookmark = false;
  bool isScrollingUp = false;
  bool reachedTheBottom = true;
  bool isExpanded = false;
  bool isWideScreen = false;
  bool isSaved = false;
  Timer? _scrollTimer;
  late String poemTitle = "";
  List<String> poetryFeatures = [];
  late ScrollController _scrollController;
  ScrollController _sheetScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<dynamic> _googleFonts = [
    ["ebGaramond", GoogleFonts.ebGaramond().fontFamily!],
    ["monofett", GoogleFonts.monofett().fontFamily!],
    ["k2d", GoogleFonts.k2d().fontFamily!],
    ["oswald", GoogleFonts.oswald().fontFamily!],
    ["zhiMangXing", GoogleFonts.zhiMangXing().fontFamily!],
    ["zenTokyoZoo", GoogleFonts.zenTokyoZoo().fontFamily!],
  ];
  late List<dynamic> _aiTools;
  late String poetryMetre = "";
  bool _dialVisible = true;
  double _currentSheetHeight = 0.3;
  double _initialDragOffset = 0.0;
  double _minChildSize = 0.3;

  // final HttpsCallable _addNumbers =
  //     FirebaseFunctions.instanceFor(region: 'us-central1')
  //         .httpsCallable('addNumbers');

  // Future<void> _callAddNumbersFunction() async {
  //   try {
  //     final result = await _addNumbers.call({
  //       'num1': 5,
  //       'num2': 7,
  //     });

  //     final int sum = result.data['result'];
  //     print('Sum: $sum');
  //   } on FirebaseFunctionsException catch (e) {
  //     print('Error calling addNumbers: $e');
  //   } catch (e) {
  //     print('Unexpected error calling addNumbers: $e');
  //   }
  // }

  List<String> bookmarks = [];
  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ),
      vsync: this,
    );
    currentAdsCounter = adsCounterStore.get('adsCounter') ?? 1;
    super.initState();
    _scrollController = ScrollController();
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    poemTitle = poemData['title'] as String;
    String? poetryContent = poemData['poetry'] as String?;
    String? poetryMetre = poemData['meter'] as String?;
    poetryFeatures = poemData['features'];
    String? poetryType = poemData['type'] as String;
    bookmarks = poemData['bookmarks'] as List<String>;
    _aiTools = [
      [
        1,
        "images/dante.png",
        "Review The Whole Poem",
        "See whether your poetical work follows all the features to be called a work of $poetryType.",
      ],
      [
        2,
        "images/rhyme.png",
        "Rhyme Selected Lines",
        "Select two lines from the editor and make both of them rhyme without changing the general meaning."
      ],
      [
        3,
        "images/meter.png",
        "Metre",
        "Find the metre pattern for the whole poem. Uppercase for stressed syllables and Lowercase for unstressed."
      ],
      [
        4,
        "images/rhyme.png",
        "Rhyme Scheme Pattern",
        "Find the rhyming scheme pattern for the whole poem."
      ],
      [
        5,
        "images/meter.png",
        "Convert Your Lines Into $poetryMetre",
        "Generate lines that adhere to the proper poetry metre form."
      ],
      [6, "images/rhyme.png", "Rhyme Whole Poem", "Placeholder text"],
      [
        7,
        "images/poetry.png",
        "Few Lines For Inspiration",
        "Generate few lines that inspire and help you unleash your creativity."
      ],
      [8, "images/dante.png", "Get Inspired", "Placeholder text"],
      [9, "images/lines.png", "Generate Theme Ideas", "Placeholder text"],
      [10, "images/book.png", "What To Write About Next?", "Placeholder text"],
    ];
    var myJSON = poetryContent != null ? jsonDecode(poetryContent) : null;
    controller = quill.QuillController(
      document:
          myJSON != null ? quill.Document.fromJson(myJSON) : quill.Document(),
      keepStyleOnNewLine: true,
      selection: const TextSelection.collapsed(offset: 0),
    );
    bool isFirstFocus = true;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && isFirstFocus) {
        _scrollToCursor();
        isFirstFocus = false;
      }
    });
    controller.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    String? poetryContent = poemData['poetry'] as String?;
    final hasNewContent = controller.document.toPlainText() != poetryContent;
    if (hasNewContent) {
      isSaved = false;
    }
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
    _scrollController.dispose();
    _animationController.dispose();
    // keyboardSubscription.cancel();
    super.dispose();
  }

//CURSOR OFFSET RETURNS THE PLAINTEXT FROM CURSOR POSITION
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

  String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      int kValue = (number ~/ 1000);
      return '${kValue}k';
    } else if (number < 1000000000) {
      int mValue = (number ~/ 1000000);
      return '${mValue}m';
    } else {
      int bValue = (number ~/ 1000000000);
      return '${bValue}b';
    }
  }

  bool isFirstLineSelected = false;
  bool isSecondLineSelected = false;
  bool isConvertToMetreSelected = false;
  String selectedLine1 = "";
  String selectedLine2 = "";
  List<String> selectedLines = [];
  String multiSelectedLines = "";
  final globalThemeBox = Hive.box('myThemeBox');
  bool tester = false;
  @override
  Widget build(BuildContext context) {
    int toAdsCount = context.watch<AuthService>().toAdsCount;
    final themeValue = globalThemeBox.get('theme') ?? 'Classic';
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    String metre = poemData['meter'] as String;
    final isRhymeSelectedLines =
        context.watch<AuthService>().isRhymeSelectedLines;
    final isConvertToMetre = context.watch<AuthService>().isConvertToMetre;

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
          leading: !isRhymeSelectedLines && !isConvertToMetre
              ? IconButton(
                  onPressed: () {
                    if (!isSaved) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: ColorTheme.accent(themeValue),
                              title: Text(
                                "Would You Like To Save ?",
                                style: TextStyle(
                                    fontSize: !isWideScreen ? 20 : 26,
                                    color: Colors.black,
                                    fontFamily:
                                        GoogleFonts.ebGaramond().fontFamily),
                              ),
                              actions: [
                                TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                ColorTheme.primary(
                                                    themeValue))),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage(),
                                          ));
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontSize: !isWideScreen ? 20 : 26,
                                          color: Colors.black,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily),
                                    )),
                                TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                ColorTheme.primary(
                                                    themeValue))),
                                    onPressed: () async {
                                      setState(() {
                                        isSaved = true;
                                        var poemData =
                                            poemListBox.getAt(widget.poemIndex)
                                                as Map<dynamic, dynamic>;
                                        poemData['poetry'] = jsonEncode(
                                            controller.document
                                                .toDelta()
                                                .toJson());
                                        poemListBox.putAt(
                                            widget.poemIndex, poemData);
                                        showToast("Poem Saved!");
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage(),
                                            ));
                                      });
                                    },
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                          fontSize: !isWideScreen ? 20 : 26,
                                          color: Colors.black,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily),
                                    )),
                              ],
                            );
                          });
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ));
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ))
              : IconButton(
                  onPressed: () {
                    if (isRhymeSelectedLines) {
                      context.read<AuthService>().isRhymeSelectedLines = false;
                      setState(() {
                        isFirstLineSelected = false;
                        isSecondLineSelected = false;
                      });
                    } else if (isConvertToMetre) {
                      context.read<AuthService>().isConvertToMetre = false;
                      setState(() {
                        isConvertToMetreSelected = false;
                      });
                    }
                  },
                  iconSize: 30,
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: "Click on this if you want to cancel the selection",
                ),
          title: !isConvertToMetre
              ? Text(
                  !isRhymeSelectedLines
                      ? "Editor - $poemTitle"
                      : !isFirstLineSelected
                          ? "Select Line 1 To Rhyme"
                          : !isSecondLineSelected
                              ? "Select Line 2 To Rhyme"
                              : "",
                  style: GoogleFonts.ebGaramond(
                    textStyle: !isWideScreen
                        ? TextStyle(
                            fontSize: 18,
                            color: widget.editorFontColor,
                            letterSpacing: .5,
                            // fontSize: 18,
                          )
                        : TextStyle(
                            fontSize: 26,
                            color: widget.editorFontColor,
                            letterSpacing: .5,
                            // fontSize: 18,
                          ),
                  ),
                )
              : Text(
                  "Select Line(s)",
                  style: GoogleFonts.ebGaramond(
                    textStyle: !isWideScreen
                        ? TextStyle(
                            fontSize: 18,
                            color: widget.editorFontColor,
                            letterSpacing: .5,
                          )
                        : TextStyle(
                            fontSize: 28,
                            color: widget.editorFontColor,
                            letterSpacing: .5,
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
            !isRhymeSelectedLines && !isConvertToMetre
                ? IconButton(
                    onPressed: () async {
                      // ignore: use_build_context_synchronously
                      final incrementCounter = context.read<AuthService>();
                      incrementCounter.incrementAdsCounter();
                      currentAdsCounter = toAdsCount;
                      adsCounterStore.put('adsCounter', toAdsCount);
                      // print(currentAdsCounter);
                      // print("THE ADS COUNTER IS: $toAdsCount");
                      if (currentAdsCounter >= 5) {
                        // ignore: use_build_context_synchronously
                        final reset = context.read<AuthService>();
                        reset.resetAdsCounter();
                        currentAdsCounter = toAdsCount;
                        adsCounterStore.put('adsCounter', currentAdsCounter);
                        print("SHOW ME THE FUCKING ADS!");
                      }
                      var poemData = poemListBox.getAt(widget.poemIndex)
                          as Map<dynamic, dynamic>;
                      poemTitle = poemData['title'] as String;
                      String? poetryContent = poemData['poetry'] as String?;
                      String? poetryMetre = poemData['meter'] as String?;
                      print(poetryMetre);
                      poetryFeatures = poemData['features'];
                      String? poetryType = poemData['type'] as String;
                      String allFeatures = poetryFeatures.join(", ");
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Features',
                                    style: !isWideScreen
                                        ? TextStyle(
                                            fontSize: 20,
                                            color: widget.editorFontColor,
                                            letterSpacing: .5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: GoogleFonts.ebGaramond()
                                                .fontFamily)
                                        : TextStyle(
                                            fontSize: 28,
                                            color: widget.editorFontColor,
                                            letterSpacing: .5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: GoogleFonts.ebGaramond()
                                                .fontFamily),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                      height:
                                          10), // Add spacing between the title and content
                                  SingleChildScrollView(
                                    child: Text(
                                      allFeatures,
                                      style: !isWideScreen
                                          ? TextStyle(
                                              fontSize: 18,
                                              color: widget.editorFontColor,
                                              letterSpacing: .5,
                                              fontFamily:
                                                  GoogleFonts.ebGaramond()
                                                      .fontFamily)
                                          : TextStyle(
                                              fontSize: 28,
                                              color: widget.editorFontColor,
                                              letterSpacing: .5,
                                              fontFamily:
                                                  GoogleFonts.ebGaramond()
                                                      .fontFamily),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      size: 30,
                      Icons.info,
                      color: widget.editorFontColor,
                    ),
                  )
                : !isFirstLineSelected && !isConvertToMetreSelected
                    ? IconButton(
                        onPressed: () {
                          if (isRhymeSelectedLines) {
                            setState(() {
                              selectedLine1 =
                                  getSelectedTextAsPlaintext(controller);
                              selectedLines.add(selectedLine1);
                            });
                            // print(selectedLine1);
                            if (selectedLine1.isEmpty) {
                              showToast(
                                  "Select a line so that you can rhyme them!");
                            } else if (selectedLine1.isNotEmpty) {
                              setState(() {
                                isFirstLineSelected = true;
                              });
                              showToast(
                                  "Select another line to rhyme with the last selected line!");
                            }
                          }
                          if (isConvertToMetre) {
                            setState(() {
                              multiSelectedLines =
                                  getSelectedTextAsPlaintext(controller);
                            });
                            if (multiSelectedLines.isEmpty) {
                              showToast(
                                  "Select a line, convert it into proper metre form!");
                            } else if (multiSelectedLines.isNotEmpty) {
                              setState(() {
                                context.read<AuthService>().isConvertToMetre =
                                    false;
                                setState(() {
                                  isConvertToMetreSelected = false;
                                });
                              });
                              showToast("Converting ...");
                              print(selectedLines);
                              _AiToolsListState()
                                  .aiToolsSelected(
                                      5,
                                      controller,
                                      poetryFeatures,
                                      selectedLines,
                                      multiSelectedLines,
                                      metre)
                                  .then((value) {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  builder: (context) {
                                    print(controller);
                                    print(poetryFeatures);
                                    print(metre);
                                    print(selectedLines);
                                    return CustomModalBottomSheet(
                                      title: "Convert Into Proper Metre",
                                      content: value,
                                      animation: _animationController,
                                      poemIndex: widget.poemIndex,
                                      buttonColor: widget.editorAppbarColor,
                                      fontColor: widget.editorFontColor,
                                      controller: controller,
                                      multiSelectedLines: multiSelectedLines,
                                      poetryFeatures: poetryFeatures,
                                      poetryMetre: metre,
                                      selectedLines: selectedLines,
                                      userChoice: 5,
                                    );
                                  },
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.check),
                        tooltip:
                            "Click on this after selecting a line in the editor",
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            selectedLine2 =
                                getSelectedTextAsPlaintext(controller);
                            selectedLines.add(selectedLine2);
                          });
                          if (selectedLine2.isEmpty) {
                            showToast(
                                "Select the second line so that you can rhyme them!");
                          } else if (selectedLine2.isNotEmpty) {
                            setState(() {
                              isSecondLineSelected = true;
                            });
                            if (isSecondLineSelected) {
                              context.read<AuthService>().isRhymeSelectedLines =
                                  false;
                              setState(() {
                                isFirstLineSelected = false;
                                isSecondLineSelected = false;
                              });
                              showToast("Rhyming In Process ...");
                              _AiToolsListState()
                                  .aiToolsSelected(
                                2,
                                controller,
                                poetryFeatures,
                                selectedLines,
                                multiSelectedLines,
                                poetryMetre,
                              )
                                  .then(
                                (value) {
                                  List<String> regenerateSelectedLines = [];
                                  regenerateSelectedLines = selectedLines;
                                  print(selectedLines);
                                  selectedLines = [];
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    builder: (context) {
                                      return CustomModalBottomSheet(
                                        title: "Rhyme Selected Lines",
                                        content: value,
                                        animation: _animationController,
                                        poemIndex: widget.poemIndex,
                                        buttonColor: widget.editorAppbarColor,
                                        fontColor: widget.editorFontColor,
                                        controller: controller,
                                        multiSelectedLines: multiSelectedLines,
                                        poetryFeatures: poetryFeatures,
                                        selectedLines: regenerateSelectedLines,
                                        poetryMetre: metre,
                                        userChoice: 2,
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check)),
          ],
        ),
        body: SafeArea(
          child: Column(children: [
            quill.QuillToolbar.basic(
              controller: controller,
              toolbarIconSize: !isWideScreen ? 20 : 30,
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
              showCodeBlock: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showStrikeThrough: false,
              showAlignmentButtons: false,
              showClearFormat: false,
              color: Colors.grey,
              showFontSize: true,
              showFontFamily: true,
              fontSizeValues: const {
                'Small': '21',
                'Medium': '26',
                'Large': '32',
              },
              fontFamilyValues: {
                for (var fontFamily in _googleFonts)
                  fontFamily[0]: fontFamily[1]
              },
            ),
            Expanded(
              flex: 1,
              child: Stack(children: [
                NotificationListener(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollStartNotification) {
                      setState(() {
                        _dialVisible = false;
                      });
                    } else if (scrollNotification is ScrollEndNotification) {
                      setState(() {
                        _dialVisible = true;
                      });
                    }
                    return true;
                  },
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
                              fontSize: !isWideScreen ? 21 : 29,
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
                Visibility(
                  visible: showBookmarkModal,
                  // child: NotificationListener<DraggableScrollableNotification>(
                  //   onNotification: (notification) {
                  //     if (notification.extent == notification.minExtent) {
                  //       setState(() {
                  //         // showBookmarkModal = false;
                  //         // tester = true;
                  //       });
                  //     }
                  //     return false;
                  //   },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification) {
                        if (notification.metrics.axis == Axis.vertical) {
                          setState(() {
                            reachedTheBottom = true;
                          });
                        }
                      }
                      return false;
                    },
                    child: DraggableScrollableActuator(
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.5,
                        minChildSize: 0.5,
                        maxChildSize: 1,
                        snap: true,
                        builder: (context, scrollController) {
                          _sheetScrollController = scrollController;
                          var poemBookmarks =
                              poemData['bookmarks'] as List<String>;
                          int count = poemBookmarks.length;
                          String formattedCount = formatNumber(count);
                          return Container(
                            color: Colors.white,
                            child: CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                SliverAppBar(
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showBookmarkModal = false;
                                          reachedTheBottom = true;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                  leading: const Icon(
                                    Icons.bookmark_added,
                                    color: Colors.black,
                                  ),
                                  pinned: true,
                                  backgroundColor: widget.editorAppbarColor,
                                  expandedHeight: 50, // Adjust as needed
                                  flexibleSpace: FlexibleSpaceBar(
                                    title: Text(
                                      "Bookmarks-$formattedCount",
                                      style: GoogleFonts.ebGaramond(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .5,
                                          fontSize: !isWideScreen ? 18 : 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Check if bookmarks list is empty
                                if (poemBookmarks.isEmpty)
                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: Text(
                                        "No Bookmarks Yet ...",
                                        style: TextStyle(
                                            fontSize: !isWideScreen ? 18 : 28,
                                            color: Colors.black,
                                            fontFamily: GoogleFonts.ebGaramond()
                                                .fontFamily),
                                      ),
                                    ),
                                  )
                                else
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        bool readMoreClicked = true;
                                        var poemData =
                                            poemListBox.getAt(widget.poemIndex)
                                                as Map<dynamic, dynamic>;
                                        String content =
                                            poemData['bookmarks'][index];
                                        List<String> bookmark =
                                            poemData['bookmarks'];
                                        return Slidable(
                                          key: const ValueKey(0),
                                          enabled: readMoreClicked,
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              // SlidableAction(
                                              //   onPressed: (context) {},
                                              //   backgroundColor:
                                              //       const Color(0xFF21B7CA),
                                              //   foregroundColor:
                                              //       Colors.white,
                                              //   icon: Icons.share,
                                              //   label: 'Share',
                                              // ),
                                              SlidableAction(
                                                onPressed: (context) {
                                                  setState(() {
                                                    bookmark.removeAt(index);
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: widget
                                                          .editorAppbarColor,
                                                      content: Text(
                                                        'Bookmark deleted.',
                                                        style: TextStyle(
                                                            fontSize:
                                                                !isWideScreen
                                                                    ? 18
                                                                    : 28,
                                                            color: widget
                                                                .editorFontColor),
                                                      ),
                                                      action: SnackBarAction(
                                                        backgroundColor: widget
                                                            .editorPrimaryColor,
                                                        label: 'Undo',
                                                        textColor: widget
                                                            .editorFontColor,
                                                        onPressed: () {
                                                          setState(() {
                                                            bookmark
                                                                .add(content);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                backgroundColor:
                                                    const Color(0xFFFE4A49),
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete,
                                                label: 'Delete',
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
                                                child: Container(
                                                  color: Colors.white,
                                                  child: ListTile(
                                                    title:
                                                        ReadMoreText.selectable(
                                                      content,
                                                      numLines: 2,
                                                      style: GoogleFonts
                                                          .ebGaramond(
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
                                                          letterSpacing: .5,
                                                          fontSize:
                                                              !isWideScreen
                                                                  ? 18
                                                                  : 28,
                                                        ),
                                                      ),
                                                      readMoreTextStyle:
                                                          GoogleFonts
                                                              .ebGaramond(
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
                                                          letterSpacing: .5,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              !isWideScreen
                                                                  ? 18
                                                                  : 28,
                                                        ),
                                                      ),
                                                      readMoreIconColor:
                                                          Colors.black,
                                                      readMoreText: 'Read more',
                                                      onReadMoreClicked: () =>
                                                          setState(() {
                                                        readMoreClicked =
                                                            !readMoreClicked;
                                                      }),
                                                      readLessText: 'Read less',
                                                      readMoreAlign:
                                                          AlignmentDirectional
                                                              .bottomStart,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                height: 1,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      childCount: poemBookmarks.length,
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        floatingActionButton: showBookmarkModal
            ? Visibility(
                visible: reachedTheBottom,
                child: bookmarks.isNotEmpty
                    ? FloatingActionButton.small(
                        backgroundColor: widget.editorAppbarColor,
                        child: Icon(
                          Icons.arrow_downward,
                          color: widget.editorFontColor,
                        ),
                        onPressed: () {
                          setState(() {
                            scrollToBottomOfBookmark = true;
                          });
                          if (scrollToBottomOfBookmark) {
                            _sheetScrollController.animateTo(
                              _sheetScrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            reachedTheBottom = false;
                          }
                        },
                      )
                    : Container(),
              )
            : !isRhymeSelectedLines && !isConvertToMetre
                ? Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.15),
                    child: SpeedDial(
                      onOpen: () {
                        setState(() {
                          FocusScope.of(context).unfocus();
                        });
                      },
                      visible: _dialVisible,
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
                            child: const Icon(Icons.smart_button_sharp),
                            label: 'AI Poetry Tool',
                            labelStyle: GoogleFonts.ebGaramond(
                              textStyle: TextStyle(
                                color: Colors.black,
                                letterSpacing: .5,
                                fontSize: !isWideScreen ? 18 : 28,
                              ),
                            ),
                            backgroundColor: widget.editorAppbarColor,
                            onTap: () {
                              setState(() {
                                showBookmarkModal = false;
                              });
                              showModalBottomSheet(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Container(
                                                    height: 5,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 20, 10, 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      _isInfoClicked
                                                          ? 'How To Get Started'
                                                          : 'AI Tools:',
                                                      style: GoogleFonts
                                                          .ebGaramond(
                                                        textStyle: TextStyle(
                                                          color: Colors.black,
                                                          letterSpacing: .5,
                                                          fontSize:
                                                              !isWideScreen
                                                                  ? 22
                                                                  : 28,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _isInfoClicked =
                                                              !_isInfoClicked;
                                                        });
                                                      },
                                                      child: Icon(
                                                        _isInfoClicked
                                                            ? Icons.arrow_back
                                                            : Icons
                                                                .info_outline,
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
                                                      controller: controller,
                                                      poetryFeatures:
                                                          poetryFeatures,
                                                      selectedLines:
                                                          selectedLines,
                                                      multiSelectedLines:
                                                          multiSelectedLines,
                                                      poetryMetre: poetryMetre,
                                                      animation:
                                                          _animationController,
                                                      poemIndex:
                                                          widget.poemIndex,
                                                      primaryColor: widget
                                                          .editorAppbarColor,
                                                      fontColor: widget
                                                          .editorFontColor,
                                                      userChoice: 0,
                                                    ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  });
                            }),
                        SpeedDialChild(
                          child: const Icon(Icons.bookmark_added_rounded),
                          label: 'Saved Bookmarks',
                          labelStyle: GoogleFonts.ebGaramond(
                            textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: !isWideScreen ? 18 : 28,
                            ),
                          ),
                          backgroundColor: widget.editorAppbarColor,
                          onTap: () async {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              showBookmarkModal = !showBookmarkModal;
                            });
                          },
                        ),
                        SpeedDialChild(
                          child: const Icon(Icons.save),
                          label: 'Save The Poem',
                          labelStyle: GoogleFonts.ebGaramond(
                            textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: !isWideScreen ? 18 : 28,
                            ),
                          ),
                          backgroundColor: widget.editorAppbarColor,
                          onTap: () async {
                            setState(() {
                              isSaved = true;
                              var poemData = poemListBox.getAt(widget.poemIndex)
                                  as Map<dynamic, dynamic>;
                              poemData['poetry'] = jsonEncode(
                                  controller.document.toDelta().toJson());
                              poemListBox.putAt(widget.poemIndex, poemData);
                              showToast("Poem Saved!");
                            });
                          },
                        ),
                        SpeedDialChild(
                          child: const Icon(Icons.check),
                          label: 'Finish Poem',
                          labelStyle: GoogleFonts.ebGaramond(
                            textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: !isWideScreen ? 18 : 28,
                            ),
                          ),
                          backgroundColor: widget.editorAppbarColor,
                          onTap: () async {
                            isSaved = true;
                            var poemData = poemListBox.getAt(widget.poemIndex)
                                as Map<dynamic, dynamic>;
                            poemData['poetry'] = jsonEncode(
                                controller.document.toDelta().toJson());
                            poemListBox.putAt(widget.poemIndex, poemData);
                            showToast("Poem Saved!");
                            String poem = controller.document.toPlainText();
                            print(controller.document.toPlainText());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GiveTitle(
                                    poem: poem,
                                    accentColor: ColorTheme.accent(themeValue),
                                    primaryColor:
                                        ColorTheme.primary(themeValue),
                                    textColor: ColorTheme.text(themeValue),
                                  ),
                                ));
                          },
                        ),
                      ],
                    ),
                  )
                : null,
        floatingActionButtonLocation: showBookmarkModal
            ? FloatingActionButtonLocation.miniEndFloat
            : FloatingActionButtonLocation.endTop,
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
      fontSize: !isWideScreen ? 18 : 28,
    );
  }
}

class AiToolsList extends StatefulWidget {
  const AiToolsList({
    super.key,
    required List aiTools,
    required this.controller,
    required this.poetryFeatures,
    required this.selectedLines,
    required this.multiSelectedLines,
    required this.poetryMetre,
    required this.animation,
    required this.poemIndex,
    required this.primaryColor,
    required this.fontColor,
    required this.userChoice,
  }) : _aiTools = aiTools;

  final List _aiTools;
  final quill.QuillController controller;
  final List<String> poetryFeatures;
  final List<String> selectedLines;
  final String multiSelectedLines;
  final String poetryMetre;
  final AnimationController animation;
  final int poemIndex;
  final Color primaryColor;
  final Color fontColor;
  final int userChoice;
  @override
  State<AiToolsList> createState() => _AiToolsListState();
}

class _AiToolsListState extends State<AiToolsList> {
  String wordResponse = "";
  bool isWideScreen = false;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    final isRhymeSelectedLines =
        context.watch<AuthService>().isRhymeSelectedLines;
    final isConvertToMetre = context.watch<AuthService>().isConvertToMetre;
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget._aiTools.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.primaryColor),
                      ),
                    );
                  },
                );
                String aiToolsSelectTitle = widget._aiTools[index][2];
                aiToolsSelected(
                  widget._aiTools[index][0],
                  widget.controller,
                  widget.poetryFeatures,
                  widget.selectedLines,
                  widget.multiSelectedLines,
                  widget.poetryMetre,
                ).then((response) {
                  // print(response);
                  setState(() {
                    if (widget._aiTools[index][0] == 5) {
                      context.read<AuthService>().isConvertToMetre =
                          !isConvertToMetre;
                      Navigator.of(context).pop();
                    }
                    if (widget._aiTools[index][0] == 2) {
                      context.read<AuthService>().isRhymeSelectedLines =
                          !isRhymeSelectedLines;
                      Navigator.of(context).pop();
                    }
                    wordResponse = response;
                    Navigator.of(context).pop();
                    !context.read<AuthService>().isRhymeSelectedLines &&
                            !context.read<AuthService>().isConvertToMetre
                        ? showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            builder: (context) {
                              return CustomModalBottomSheet(
                                title: aiToolsSelectTitle,
                                content: wordResponse,
                                animation: widget.animation,
                                poemIndex: widget.poemIndex,
                                buttonColor: widget.primaryColor,
                                fontColor: widget.fontColor,
                                controller: widget.controller,
                                multiSelectedLines: widget.multiSelectedLines,
                                poetryFeatures: widget.poetryFeatures,
                                poetryMetre: widget.poetryMetre,
                                selectedLines: widget.selectedLines,
                                userChoice: widget._aiTools[index][0],
                              );
                            },
                          )
                        : null;
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
                        textStyle: TextStyle(
                          color: Colors.black,
                          letterSpacing: .5,
                          fontSize: !isWideScreen ? 18 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      widget._aiTools[index][3],
                      style: GoogleFonts.ebGaramond(
                        textStyle: TextStyle(
                          color: Colors.black,
                          letterSpacing: .5,
                          fontSize: !isWideScreen ? 18 : 28,
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
    int? userChoice,
    quill.QuillController controller,
    List<String> poetryFeatures,
    List<String> selectedLines,
    String multiSelectedLines,
    String poetryMetre,
  ) async {
    AiToolsHandler aiToolsHandler = AiToolsHandler();
    switch (userChoice) {
      case 1:
        return await aiToolsHandler.reviewTheFeatures(
            controller, poetryFeatures);
      case 2:
        return await aiToolsHandler.rhymeSelectedLines(selectedLines);
      case 3:
        return await aiToolsHandler.metreHighlighter(controller);
      case 4:
        return await aiToolsHandler.rhymeSchemePattern(controller);
      case 5:
        return await aiToolsHandler.convertLinesToProperMetreForm(
            multiSelectedLines, poetryMetre);
      case 6:
        aiToolsHandler.poemInspiration();
        return "";
      case 7:
        return await aiToolsHandler.generateFewLinesForInspiration(controller);
      default:
        print('Invalid choice.');
        return "";
    }
  }
}

// ignore: must_be_immutable
class CustomModalBottomSheet extends StatefulWidget {
  final String title;
  String content;
  final AnimationController animation;
  final int poemIndex;
  final Color buttonColor;
  final Color fontColor;
  final quill.QuillController controller;
  final List<String> poetryFeatures;
  List<String> selectedLines;
  final String multiSelectedLines;
  final String poetryMetre;
  final int? userChoice;
  CustomModalBottomSheet({
    super.key,
    required this.title,
    required this.content,
    required this.animation,
    required this.poemIndex,
    required this.buttonColor,
    required this.fontColor,
    required this.controller,
    required this.poetryFeatures,
    required this.selectedLines,
    required this.multiSelectedLines,
    required this.poetryMetre,
    this.userChoice,
  });

  @override
  State<CustomModalBottomSheet> createState() => _CustomModalBottomSheetState();
}

class _CustomModalBottomSheetState extends State<CustomModalBottomSheet> {
  late StateMachineController? _riveController;
  SMIInput<bool>? isRiveClicked;
  final poemListBox = Hive.box('myPoemBox');
  bool isClicked = false;
  bool isRegenerated = false;
  List<String> bookmark = [];
  late String newGeneratedLines = "";
  @override
  void initState() {
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    bookmark = poemData['bookmarks'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    void saveOrRemovePoem() {
      if (isClicked) {
        bookmark.removeLast();
        Fluttertoast.showToast(
          msg: "Bookmark removed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: !isWideScreen ? 18 : 28,
          backgroundColor: widget.buttonColor,
          textColor: widget.fontColor,
        );
      } else {
        bookmark.add(widget.content);
        var poemData =
            poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
        poemData['bookmarks'] = bookmark;
        poemListBox.putAt(widget.poemIndex, poemData);
        var poemBookmarks = poemData['bookmarks'] as List<String>;
        for (var i = 0; i < poemBookmarks.length; i++) {
          var bookm = poemBookmarks[i];
          print("bookmark $i : $bookm");
        }
        Fluttertoast.showToast(
          msg: "Bookmarked!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: !isWideScreen ? 18 : 28,
          backgroundColor: widget.buttonColor,
          textColor: widget.fontColor,
        );
      }
      setState(() {
        isClicked = !isClicked;
      });
    }

    void resetRiveAnimation() {
      isRiveClicked?.change(false);
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 5,
                  width: MediaQuery.of(context).size.width * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.ebGaramond(
                      textStyle: TextStyle(
                        color: Colors.black,
                        letterSpacing: .5,
                        fontSize: !isWideScreen ? 18 : 28,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isRiveClicked == null) return;
                      final isClick = isRiveClicked?.value ?? false;
                      isRiveClicked?.change(!isClick);
                      saveOrRemovePoem();
                    },
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: RiveAnimation.asset(
                        'assets/bookmark.riv',
                        fit: BoxFit.cover,
                        stateMachines: const ['Bookmark State Machine'],
                        onInit: (artboard) {
                          _riveController = StateMachineController.fromArtboard(
                              artboard, "Bookmark State Machine");
                          if (_riveController == null) return;
                          artboard.addController(_riveController!);
                          isRiveClicked =
                              _riveController?.findInput<bool>("Marked");
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 20.0, right: 8.0, bottom: 8.0),
                      child: !isRegenerated
                          ? Text(
                              widget.content,
                              style: GoogleFonts.ebGaramond(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  letterSpacing: .5,
                                  fontSize: !isWideScreen ? 18 : 28,
                                ),
                              ),
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.buttonColor),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: SizedBox(
                          width: 60,
                          height: 60,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(widget.fontColor),
                                iconColor:
                                    MaterialStateProperty.all(widget.fontColor),
                                backgroundColor: MaterialStateProperty.all(
                                    widget.buttonColor)),
                            onPressed: () {
                              setState(() {
                                isRegenerated = true;
                                widget.content = "";
                              });
                              _AiToolsListState()
                                  .aiToolsSelected(
                                      widget.userChoice,
                                      widget.controller,
                                      widget.poetryFeatures,
                                      widget.selectedLines,
                                      widget.multiSelectedLines,
                                      widget.poetryMetre)
                                  .then((value) {
                                print(widget.userChoice);
                                print(widget.controller);
                                print(widget.poetryFeatures);
                                print(widget.selectedLines);
                                print(widget.multiSelectedLines);
                                print(widget.poetryMetre);
                                setState(() {
                                  widget.content = value;
                                  if (widget.content.isNotEmpty) {
                                    isRegenerated = false;
                                  }
                                });
                              });
                              if (widget.content.isEmpty) {
                                setState(() {
                                  isClicked = false;
                                });
                                resetRiveAnimation();
                              }
                            },
                            child: const Icon(Icons.autorenew, size: 25),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    return Text(
      "Write the info to help user here:",
      style: !isWideScreen
          ? TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontFamily: GoogleFonts.ebGaramond().fontFamily)
          : TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontFamily: GoogleFonts.ebGaramond().fontFamily),
    );
  }
}

class AiToolsHandler {
  Future<String> rhymeSchemePattern(quill.QuillController controller) async {
    print('Executing RhymeSchemePattern...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response = await PoetryAiTools().callRhymeSchemeFinder(plainText);
    return response;
  }

  Future<String> metreHighlighter(quill.QuillController controller) async {
    print('Executing MetreHighlighter...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response =
        await PoetryAiTools().callPoeticMetreFinderFunction(plainText);
    return response;
  }

  Future<void> poemInspiration() async {
    print('Executing PoemInspiration...');
    // Your implementation for PoemInspiration here
  }

  Future<String> convertLinesToProperMetreForm(
      String selectedLines, String poetryMetre) async {
    print('Executing convertLinesToProperMetreForm');
    String response = await PoetryAiTools()
        .callChangeLinesToFollowMetreFunction(selectedLines, poetryMetre);
    return response;
  }

  Future<String> reviewTheFeatures(
      quill.QuillController controller, List<String> poetryFeatures) async {
    print('Executing reviewTheFeatures...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response = await PoetryAiTools()
        .callReviewTheFeaturesFunction(plainText, poetryFeatures);
    return response;
  }

  Future<String> rhymeSelectedLines(List<String> selectedLines) async {
    print('Executing RhymeSelectedLines...');
    String response =
        await PoetryAiTools().callRhymeTwoSelectedLinesFunction(selectedLines);
    return response;
  }

  Future<String> generateFewLinesForInspiration(
      quill.QuillController controller) async {
    print('Executing GenerateFewLinesForInspiration...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response = await PoetryAiTools()
        .callGenerateFewLinesForInspirationFunction(plainText);
    return response;
  }
}
