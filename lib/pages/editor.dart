import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/api/poetry_ai.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/components/inline_adaptive_banner.dart';
import 'package:poetry_ai/pages/give_title.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rive/rive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:read_more_text/read_more_text.dart';

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
  bool _isInfoClicked = false;
  bool showBookmarkModal = false;
  bool scrollToBottomOfBookmark = false;
  bool isScrollingUp = false;
  bool reachedTheBottom = true;
  bool isExpanded = false;
  bool isWideScreen = false;
  bool isSaved = false;
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

  RewardedAd? rewardedAd;
  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-6492537624854863/8085373221'
      : 'ca-app-pub-6492537624854863/8085373221';

  /// Loads a rewarded ad.
  void loadRewardAd() {
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            loadRewardAd();
          },
        ));
  }

  InterstitialAd? _interstitialAd;
  // TODO: replace this test ad unit with your own ad unit.
  final adInterUnitId = Platform.isAndroid
      ? 'ca-app-pub-6492537624854863/5064458215'
      : 'ca-app-pub-6492537624854863/5064458215';

  void loadInterAd() {
    InterstitialAd.load(
        adUnitId: adInterUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  List<String> bookmarks = [];
  @override
  void initState() {
    loadRewardAd();
    loadInterAd();
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
        6,
        "images/lines.png",
        "Custom Instructions",
        "Type your own special instructions to the Poetry AI assistant.\nEg: Can you add emojis to my poem?"
      ],
      [
        2,
        "images/rhyme.png",
        "Rhyme Selected Lines",
        "Select two lines from the editor and make both of them rhyme without changing the general meaning."
      ],
      [
        5,
        "images/meter.png",
        "Convert Your Lines Into $poetryMetre",
        "Generate lines that adhere to the proper poetry metre form."
      ],
      [
        1,
        "images/dante.png",
        "Review The Whole Poem",
        "See whether your poetical work follows all the features to be called a work of $poetryType.",
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
        7,
        "images/poetry.png",
        "Few Lines For Inspiration",
        "Generate few lines that inspire and help you unleash your creativity."
      ],
      [
        8,
        "images/dante.png",
        "Get Inspired",
        "Find Inspiration, Recommendation, Trivia, Anecdote or Advice based on your poetry to unleash your creativity."
      ],
      [
        9,
        "images/book.png",
        "Recommendations",
        "Get poetry recommendations depending your poetry writing style to enhance your poetry writing skills."
      ],
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
    rewardedAd!.dispose();
    _interstitialAd?.dispose();
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

    if (start < end) {
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
  String selectedWholeRhyme = "";
  final globalThemeBox = Hive.box('myThemeBox');
  bool tester = false;
  static const _insets = 16.0;
  BannerAd? _inlineAdaptiveAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  late Orientation _currentOrientation = MediaQuery.of(context).orientation;
  FocusNode textfieldFocus = FocusNode();
  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      _isLoaded = false;
    });

    // Get an inline adaptive size for the current orientation.
    AdSize size = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
        _adWidth.truncate());

    _inlineAdaptiveAd = BannerAd(
      // TODO: replace this test ad unit with your own ad unit.
      adUnitId: 'ca-app-pub-6492537624854863/9390716035',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          print('Inline adaptive banner loaded: ${ad.responseInfo}');

          // After the ad is loaded, get the platform ad size and use it to
          // update the height of the container. This is necessary because the
          // height can change after the ad is loaded.
          BannerAd bannerAd = (ad as BannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            print('Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }

          setState(() {
            _inlineAdaptiveAd = bannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _inlineAdaptiveAd != null &&
            _isLoaded &&
            _adSize != null) {
          return Align(
            child: SizedBox(
              width: _adWidth,
              height: _adSize!.height.toDouble(),
              child: AdWidget(ad: _inlineAdaptiveAd!),
            ),
          );
        }
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadBannerAd();
        }
        return Container();
      },
    );
  }

  List<String> regenerateSelectedLines = [];
  List<String> availableRhymeSchemes = [
    'ABAB',
    'AABB',
    'ABBA',
    'Ballad-ABCB',
    'Cinquain-ABABB',
    'Couplet-AA BB CC DD',
    'Limerick-AABBA',
    'Octave-ABBA ABBA',
    'Rubaiyat-AABA or AAAA',
    'Sicilian octave-ABABABAB',
    'Simple 4-line: ABCB',
    'Petrarchan sonnet',
    'Shakespearean sonnet',
  ];
  String selectedRhymeScheme = "AABB";
  @override
  Widget build(BuildContext context) {
    final themeValue = globalThemeBox.get('theme') ?? 'Classic';
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    String metre = poemData['meter'] as String;
    final isRhymeSelectedLines =
        context.watch<AuthService>().isRhymeSelectedLines;
    final isConvertToMetre = context.watch<AuthService>().isConvertToMetre;
    final isCustomInstruct = context.watch<AuthService>().isCustomInstruct;
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
                                          builder: (context) => HomePage(
                                              rateMyApp:
                                                  RateMyApp.customConditions(
                                                      conditions:
                                                          List.empty())),
                                        ),
                                      );
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
                                        showToast("Poem Saved!", true);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(
                                                rateMyApp:
                                                    RateMyApp.customConditions(
                                                        conditions:
                                                            List.empty())),
                                          ),
                                        );
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
                          builder: (context) => HomePage(
                              rateMyApp: RateMyApp.customConditions(
                                  conditions: List.empty())),
                        ),
                      );
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
              ? FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    !isRhymeSelectedLines
                        ? "Editor - $poemTitle"
                        : !isFirstLineSelected
                            ? "Select Line 1 To Rhyme"
                            : !isSecondLineSelected
                                ? "Select Line 2 To Rhyme"
                                : "",
                    style: GoogleFonts.ebGaramond(
                      textStyle: TextStyle(
                        // fontSize: !isWideScreen ? 22 : 30,
                        color: widget.editorFontColor,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                )
              : Text(
                  "Select Line(s)",
                  style: GoogleFonts.ebGaramond(
                    textStyle: TextStyle(
                      fontSize: !isWideScreen ? 18 : 28,
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
                      // _interstitialAd?.show();
                      // loadInterAd();
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
                        onPressed: () async {
                          // _interstitialAd?.show();
                          // loadInterAd();
                          if (isRhymeSelectedLines) {
                            setState(() {
                              selectedLine1 =
                                  getSelectedTextAsPlaintext(controller);
                              selectedLines.add(selectedLine1);
                            });
                            // print(selectedLine1);
                            if (selectedLine1.isEmpty) {
                              showToast(
                                  "Select a line so that you can rhyme them!",
                                  true);
                            } else if (selectedLine1.isNotEmpty) {
                              setState(() {
                                isFirstLineSelected = true;
                              });
                              showToast(
                                  "Select another line to rhyme with the last selected line!",
                                  true);
                            }
                          }
                          if (isConvertToMetre) {
                            setState(() {
                              multiSelectedLines =
                                  getSelectedTextAsPlaintext(controller);
                            });
                            if (multiSelectedLines.isEmpty) {
                              showToast(
                                  "Select a line, convert it into proper metre form!",
                                  true);
                            } else if (multiSelectedLines.isNotEmpty) {
                              setState(() {
                                context.read<AuthService>().isConvertToMetre =
                                    false;
                                setState(() {
                                  isConvertToMetreSelected = false;
                                });
                              });
                              bool isBottomSheetOpen = false;
                              showToast("Converting ...", false);
                              String convertedText = "";
                              // ignore: use_build_context_synchronously
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                                builder: (context) {
                                  isBottomSheetOpen =
                                      true; // Set the flag to true
                                  return CustomModalBottomSheet(
                                    title: "Convert Into Proper Metre",
                                    content: convertedText,
                                    animation: _animationController,
                                    poemIndex: widget.poemIndex,
                                    buttonColor: widget.editorAppbarColor,
                                    fontColor: widget.editorFontColor,
                                    controller: controller,
                                    multiSelectedLines: multiSelectedLines,
                                    poetryFeatures: poetryFeatures,
                                    poetryMetre: metre,
                                    selectedLines: selectedLines,
                                    userChoice: 11,
                                    selectedWholeRhyme: '',
                                  );
                                },
                              );

                              convertedText = await AiToolsHandler()
                                  .convertLinesToProperMetreForm(
                                      multiSelectedLines, poetryMetre);
                              if (isBottomSheetOpen) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(
                                    context); // Close the current bottom sheet
                                // ignore: use_build_context_synchronously
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
                                        title: "Convert Into Proper Metre",
                                        content: convertedText,
                                        animation: _animationController,
                                        poemIndex: widget.poemIndex,
                                        buttonColor: widget.editorAppbarColor,
                                        fontColor: widget.editorFontColor,
                                        controller: controller,
                                        multiSelectedLines: multiSelectedLines,
                                        poetryFeatures: poetryFeatures,
                                        poetryMetre: metre,
                                        selectedLines: selectedLines,
                                        userChoice: 11,
                                        selectedWholeRhyme: '',
                                      );
                                    });
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.check),
                        tooltip:
                            "Click on this after selecting a line in the editor",
                      )
                    : IconButton(
                        onPressed: () async {
                          // _interstitialAd?.show();
                          // loadInterAd();
                          setState(() {
                            selectedLine2 =
                                getSelectedTextAsPlaintext(controller);
                            selectedLines.add(selectedLine2);
                          });
                          if (selectedLine2.isEmpty) {
                            showToast(
                                "Select the second line so that you can rhyme them!",
                                true);
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
                              bool isBottomSheetOpen = false;
                              showToast("Rhyming In Process ...", false);
                              String convertedText = "";
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                                builder: (context) {
                                  isBottomSheetOpen =
                                      true; // Set the flag to true
                                  return CustomModalBottomSheet(
                                    title: "Rhyme Selected Lines",
                                    content: convertedText,
                                    animation: _animationController,
                                    poemIndex: widget.poemIndex,
                                    buttonColor: widget.editorAppbarColor,
                                    fontColor: widget.editorFontColor,
                                    controller: controller,
                                    multiSelectedLines: multiSelectedLines,
                                    poetryFeatures: poetryFeatures,
                                    poetryMetre: metre,
                                    selectedLines: regenerateSelectedLines,
                                    userChoice: 10,
                                    selectedWholeRhyme: '',
                                  );
                                },
                              );
                              convertedText = await AiToolsHandler()
                                  .rhymeSelectedLines(selectedLines);
                              if (isBottomSheetOpen) {
                                regenerateSelectedLines = selectedLines;
                                print(selectedLines);
                                selectedLines = [];
                                // ignore: use_build_context_synchronously
                                Navigator.pop(
                                    context); // Close the current bottom sheet
                                // ignore: use_build_context_synchronously
                                showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0),
                                    ),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    return CustomModalBottomSheet(
                                      title: "Rhyme Selected Lines",
                                      content: convertedText,
                                      animation: _animationController,
                                      poemIndex: widget.poemIndex,
                                      buttonColor: widget.editorAppbarColor,
                                      fontColor: widget.editorFontColor,
                                      controller: controller,
                                      multiSelectedLines: multiSelectedLines,
                                      poetryFeatures: poetryFeatures,
                                      poetryMetre: metre,
                                      selectedLines: regenerateSelectedLines,
                                      userChoice: 10,
                                      selectedWholeRhyme: '',
                                    );
                                  },
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.check)),
          ],
        ),
        body: SafeArea(
          child: Column(children: [
            Visibility(
              visible: !isCustomInstruct,
              child: quill.QuillToolbar.basic(
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
            ),
            Visibility(
              visible: isCustomInstruct,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Write your own instruction:",
                    style: TextStyle(
                        fontSize: !isWideScreen ? 20 : 28,
                        color: Colors.black,
                        fontFamily: GoogleFonts.ebGaramond().fontFamily),
                  ),
                  // DropdownButton(
                  //   menuMaxHeight: 300.0,
                  //   items: availableRhymeSchemes.map<DropdownMenuItem<String>>(
                  //     (String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(
                  //           value,
                  //           style: TextStyle(
                  //             fontSize: !isWideScreen ? 18 : 26,
                  //             color: Colors.black,
                  //             fontFamily: GoogleFonts.ebGaramond().fontFamily,
                  //             fontWeight: value == selectedRhymeScheme
                  //                 ? FontWeight.bold
                  //                 : FontWeight.normal,
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ).toList(),
                  //   value: selectedRhymeScheme,
                  //   onChanged: (String? value) {
                  //     setState(() {
                  //       selectedRhymeScheme = value!;
                  //       print(selectedRhymeScheme);
                  //     });
                  //   },
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: textfieldFocus,
                      onChanged: (value) {
                        selectedRhymeScheme = value;
                        print(selectedRhymeScheme);
                      },
                      maxLines: 3,
                      cursorColor: ColorTheme.text(themeValue),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: ColorTheme.text(
                                  themeValue)), // Set the focused border color to black
                        ),
                        focusColor: ColorTheme.accent(themeValue),
                        hintText: "Write an instruction",
                        hintStyle: TextStyle(
                            fontSize: !isWideScreen ? 20 : 26,
                            color: Colors.black,
                            fontFamily: GoogleFonts.ebGaramond().fontFamily),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  ColorTheme.accent(themeValue))),
                          onPressed: () {
                            // Cancel button logic
                            textfieldFocus.unfocus();
                            setState(() {
                              context.read<AuthService>().isCustomInstruct =
                                  false;
                            });
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily:
                                    GoogleFonts.ebGaramond().fontFamily),
                          )),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                ColorTheme.accent(themeValue))),
                        onPressed: () async {
                          textfieldFocus.unfocus();
                          setState(() {
                            context.read<AuthService>().isCustomInstruct =
                                false;
                          });
                          showToast("Wait for a reply to your instructions...",
                              false);
                          bool isBottomSheetOpen = false;
                          String convertedText = "";
                          // ignore: use_build_context_synchronously
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            builder: (context) {
                              isBottomSheetOpen = true; // Set the flag to true
                              return CustomModalBottomSheet(
                                title: "Custom Instructions",
                                content: convertedText,
                                animation: _animationController,
                                poemIndex: widget.poemIndex,
                                buttonColor: widget.editorAppbarColor,
                                fontColor: widget.editorFontColor,
                                controller: controller,
                                multiSelectedLines: multiSelectedLines,
                                poetryFeatures: poetryFeatures,
                                poetryMetre: metre,
                                selectedLines: selectedLines,
                                userChoice: 12,
                                selectedWholeRhyme: '',
                              );
                            },
                          );

                          convertedText = await AiToolsHandler()
                              .rhymeWholePoem(controller, selectedRhymeScheme);
                          if (isBottomSheetOpen) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(
                                context); // Close the current bottom sheet
                            // ignore: use_build_context_synchronously
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
                                    title: "Custom Instructions",
                                    content: convertedText,
                                    animation: _animationController,
                                    poemIndex: widget.poemIndex,
                                    buttonColor: widget.editorAppbarColor,
                                    fontColor: widget.editorFontColor,
                                    controller: controller,
                                    multiSelectedLines: multiSelectedLines,
                                    poetryFeatures: poetryFeatures,
                                    poetryMetre: metre,
                                    selectedLines: selectedLines,
                                    userChoice: 12,
                                    selectedWholeRhyme: selectedRhymeScheme,
                                  );
                                });
                          }
                        },
                        child: Text(
                          "Instruct!",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: GoogleFonts.ebGaramond().fontFamily),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                                      child: Column(
                                        children: [
                                          Text(
                                            "No Bookmarks Yet ...",
                                            style: TextStyle(
                                                fontSize:
                                                    !isWideScreen ? 20 : 28,
                                                color: Colors.black,
                                                fontFamily:
                                                    GoogleFonts.ebGaramond()
                                                        .fontFamily),
                                          ),
                                        ],
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
                                        return Column(
                                          children: [
                                            if (index == 0)
                                              Column(
                                                children: [
                                                  _getAdWidget(),
                                                  const Divider(
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                                ],
                                              ),
                                            Slidable(
                                              key: const ValueKey(0),
                                              enabled: readMoreClicked,
                                              endActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                children: [
                                                  SlidableAction(
                                                    onPressed: (context) {
                                                      setState(() {
                                                        bookmark
                                                            .removeAt(index);
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor: widget
                                                              .editorAppbarColor,
                                                          content: Text(
                                                            'Bookmark deleted.',
                                                            style: GoogleFonts
                                                                .ebGaramond(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                letterSpacing:
                                                                    .5,
                                                                fontSize:
                                                                    !isWideScreen
                                                                        ? 18
                                                                        : 28,
                                                              ),
                                                            ),
                                                          ),
                                                          action:
                                                              SnackBarAction(
                                                            backgroundColor: widget
                                                                .editorPrimaryColor,
                                                            label: 'Undo',
                                                            textColor: widget
                                                                .editorFontColor,
                                                            onPressed: () {
                                                              setState(() {
                                                                bookmark.add(
                                                                    content);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    backgroundColor:
                                                        const Color(0xFFFE4A49),
                                                    foregroundColor:
                                                        Colors.white,
                                                    icon: Icons.delete,
                                                    label: 'Delete',
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: ListTile(
                                                        title: ReadMoreText
                                                            .selectable(
                                                          content,
                                                          numLines: 4,
                                                          style: GoogleFonts
                                                              .ebGaramond(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              letterSpacing: .5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  !isWideScreen
                                                                      ? 18
                                                                      : 28,
                                                            ),
                                                          ),
                                                          readMoreIconColor:
                                                              Colors.black,
                                                          readMoreText:
                                                              'Read more',
                                                          onReadMoreClicked:
                                                              () =>
                                                                  setState(() {
                                                            readMoreClicked =
                                                                !readMoreClicked;
                                                          }),
                                                          readLessText:
                                                              'Read less',
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
                                            ),
                                          ],
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
            ? bookmarks.isNotEmpty
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
                : Container()
            : !isRhymeSelectedLines && !isConvertToMetre && !isCustomInstruct
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
                            label: 'Poetry AI Assistant',
                            labelStyle: GoogleFonts.ebGaramond(
                              textStyle: TextStyle(
                                color: Colors.black,
                                letterSpacing: .5,
                                fontSize: !isWideScreen ? 18 : 28,
                              ),
                            ),
                            backgroundColor: widget.editorAppbarColor,
                            onTap: () {
                              // _interstitialAd?.show();
                              // loadInterAd();
                              // rewardedAd?.show(
                              //   onUserEarnedReward: (ad, reward) {},
                              // );
                              // loadRewardAd();
                              // setState(() {
                              //   showBookmarkModal = false;
                              // });
                              int toAdsCount = context
                                  .read<AuthService>()
                                  .toAdsCount; // Use read() instead of watch()
                              final incrementCounter =
                                  context.read<AuthService>();
                              incrementCounter.incrementAdsCounter();
                              currentAdsCounter = toAdsCount;
                              adsCounterStore.put('adsCounter', toAdsCount);

                              if (currentAdsCounter >= 4) {
                                final reset = context.read<AuthService>();
                                reset.resetAdsCounter();
                                currentAdsCounter = toAdsCount;
                                adsCounterStore.put(
                                    'adsCounter', currentAdsCounter);
                                print("SHOW ME THE ADS!");
                                rewardedAd?.show(
                                  onUserEarnedReward: (ad, reward) {},
                                );
                                loadRewardAd();
                              }
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
                                                          : 'AI Assistant Commands:',
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
                                                  ? InfoPage()
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
                                                      selectedWholeRhyme:
                                                          selectedWholeRhyme,
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
                              showToast("Poem Saved!", true);
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
                            rewardedAd?.show(
                              onUserEarnedReward: (ad, reward) {},
                            );
                            loadRewardAd();
                            isSaved = true;
                            var poemData = poemListBox.getAt(widget.poemIndex)
                                as Map<dynamic, dynamic>;
                            poemData['poetry'] = jsonEncode(
                                controller.document.toDelta().toJson());
                            poemListBox.putAt(widget.poemIndex, poemData);
                            showToast("Poem Saved!", true);
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

  Future showToast(String message, bool isCenter) async {
    await Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: isCenter ? ToastGravity.CENTER : ToastGravity.BOTTOM,
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
    required this.selectedWholeRhyme,
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
  final String selectedWholeRhyme;
  @override
  State<AiToolsList> createState() => _AiToolsListState();
}

class _AiToolsListState extends State<AiToolsList> {
  String wordResponse = "";
  bool isWideScreen = false;
  final globalThemeBox = Hive.box('myThemeBox');
  bool isRhymeTheWholePoem = false;
  @override
  Widget build(BuildContext context) {
    final themeValue = globalThemeBox.get('theme') ?? 'Classic';
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    final isRhymeSelectedLines =
        context.watch<AuthService>().isRhymeSelectedLines;
    final isConvertToMetre = context.watch<AuthService>().isConvertToMetre;
    final isCustomInstruct = context.watch<AuthService>().isCustomInstruct;
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget._aiTools.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                print("-----------------------------------------");
                print(widget._aiTools[index][0]);
                print("-----------------------------------------");
                String aiToolsSelectTitle = widget._aiTools[index][2];
                bool isBottomSheetOpen = false;
                String wordResponse = "";
                if (widget._aiTools[index][0] == 5) {
                  context.read<AuthService>().isConvertToMetre =
                      !isConvertToMetre;
                  Navigator.of(context).pop();
                } else if (widget._aiTools[index][0] == 2) {
                  context.read<AuthService>().isRhymeSelectedLines =
                      !isRhymeSelectedLines;
                  Navigator.of(context).pop();
                } else if (widget._aiTools[index][0] == 6) {
                  context.read<AuthService>().isCustomInstruct =
                      !isCustomInstruct;
                  Navigator.of(context).pop();
                } else {
                  !context.read<AuthService>().isRhymeSelectedLines &&
                          !context.read<AuthService>().isConvertToMetre &&
                          !context.read<AuthService>().isCustomInstruct
                      ? showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                          ),
                          builder: (context) {
                            isBottomSheetOpen = true; // Set the flag to true
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
                              selectedWholeRhyme: '',
                            );
                          },
                        )
                      : null;
                  aiToolsSelected(
                          widget._aiTools[index][0],
                          widget.controller,
                          widget.poetryFeatures,
                          widget.selectedLines,
                          widget.multiSelectedLines,
                          widget.poetryMetre,
                          widget.selectedWholeRhyme)
                      .then((response) {
                    wordResponse = response;
                    if (isBottomSheetOpen) {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context); // Close the current bottom sheet
                      // ignore: use_build_context_synchronously
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
                            selectedWholeRhyme: '',
                          );
                        },
                      ).then((value) => Navigator.pop(context));
                    }
                  });
                }
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
    String selectedWholeRhyme,
  ) async {
    AiToolsHandler aiToolsHandler = AiToolsHandler();
    switch (userChoice) {
      case 1:
        return await aiToolsHandler.reviewTheFeatures(
            controller, poetryFeatures);
      case 2:
        return "";
      case 3:
        return await aiToolsHandler.metreHighlighter(controller);
      case 4:
        return await aiToolsHandler.rhymeSchemePattern(controller);
      case 5:
        return "";
      case 6:
        return "";
      case 7:
        return await aiToolsHandler.generateFewLinesForInspiration(controller);
      case 8:
        return await aiToolsHandler.poemInspiration(controller);
      case 9:
        return await aiToolsHandler.recommendPoem(controller);
      case 10:
        return await aiToolsHandler.rhymeSelectedLines(selectedLines);
      case 11:
        return await aiToolsHandler.convertLinesToProperMetreForm(
            multiSelectedLines, poetryMetre);
      case 12:
        return await aiToolsHandler.rhymeWholePoem(
            controller, selectedWholeRhyme);
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
  final String selectedWholeRhyme;
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
    required this.selectedWholeRhyme,
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
  int currentAdsCounter = 1;
  final adsCounterStore = Hive.box('myAdsCounterStore');
  @override
  void initState() {
    loadRewardAd();
    var poemData = poemListBox.getAt(widget.poemIndex) as Map<dynamic, dynamic>;
    bookmark = poemData['bookmarks'];
    currentAdsCounter = adsCounterStore.get('adsCounter') ?? 1;
    super.initState();
  }

  RewardedAd? rewardedAd;
  int rewardGenerations = 0;
  bool isRewardAdWatched = false;
  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-6492537624854863/8085373221'
      : 'ca-app-pub-6492537624854863/8085373221';

  /// Loads a rewarded ad.
  void loadRewardAd() {
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            loadRewardAd();
          },
        ));
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
                  widget.content.isNotEmpty
                      ? GestureDetector(
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
                                _riveController =
                                    StateMachineController.fromArtboard(
                                        artboard, "Bookmark State Machine");
                                if (_riveController == null) return;
                                artboard.addController(_riveController!);
                                isRiveClicked =
                                    _riveController?.findInput<bool>("Marked");
                              },
                            ),
                          ),
                        )
                      : Container()
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
                      child: !isRegenerated && widget.content.isNotEmpty
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
                          child: widget.content.isNotEmpty
                              ? ElevatedButton(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              widget.fontColor),
                                      iconColor: MaterialStateProperty.all(
                                          widget.fontColor),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              widget.buttonColor)),
                                  onPressed: () {
                                    // _PoetryEditorState().showAds();
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
                                      widget.poetryMetre,
                                      widget.selectedWholeRhyme,
                                    )
                                        .then((value) {
                                      print(widget.userChoice);
                                      print(widget.controller);
                                      print(widget.poetryFeatures);
                                      print(widget.selectedLines);
                                      print(widget.multiSelectedLines);
                                      print(widget.poetryMetre);
                                      int toAdsCount = context
                                          .read<AuthService>()
                                          .toAdsCount; // Use read() instead of watch()
                                      final incrementCounter =
                                          context.read<AuthService>();
                                      incrementCounter.incrementAdsCounter();
                                      currentAdsCounter = toAdsCount;
                                      adsCounterStore.put(
                                          'adsCounter', toAdsCount);

                                      if (currentAdsCounter >= 4) {
                                        final reset =
                                            context.read<AuthService>();
                                        reset.resetAdsCounter();
                                        currentAdsCounter = toAdsCount;
                                        adsCounterStore.put(
                                            'adsCounter', currentAdsCounter);
                                        print("SHOW ME THE ADS!");
                                        rewardedAd?.show(
                                          onUserEarnedReward: (ad, reward) {},
                                        );
                                        loadRewardAd();
                                      }
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
                                )
                              : null),
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
  InfoPage({super.key});
  final List<String> infoTexts = [
    "1. Click on any of the AI tools to generate responses from the AI.",
    "2. Look at the App Bar above, If you want to rhyme lines or do selected lines related tasks.",
    "3. Read the title and the sub-title of the AI tool carefully.",
    "4. Wait for each of the AI tools to load properly after clicking on them.",
    "5. The response will be generated in a popup.",
  ];
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 15.0),
        child: ListView.builder(
          itemCount: infoTexts.length,
          itemBuilder: (context, index) {
            return _buildText(index, infoTexts[index], !isWideScreen);
          },
        ),
      ),
    );
  }

  Widget _buildText(int index, String text, bool isWideScreen) {
    return Text(
      text,
      style: TextStyle(
        fontSize: !isWideScreen ? 30 : 20,
        color: Colors.black,
        fontFamily: GoogleFonts.ebGaramond().fontFamily,
      ),
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

  Future<String> poemInspiration(quill.QuillController controller) async {
    print('Executing PoemInspiration...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response = await PoetryAiTools().callGetInspiredFunction(plainText);
    return response;
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

  Future<String> rhymeWholePoem(
      quill.QuillController controller, String rhymeScheme) async {
    print('Executing rhymeWholePoem...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response = await PoetryAiTools()
        .callRhymeWholePoemFunction(plainText, rhymeScheme);
    return response;
  }

  Future<String> recommendPoem(quill.QuillController controller) async {
    print('Executing recommendPoem...');
    String plainText = "";
    int len = controller.document.length;
    plainText = controller.document.getPlainText(0, len - 1);
    String response =
        await PoetryAiTools().callRecommendPoemFunction(plainText);
    return response;
  }
}
