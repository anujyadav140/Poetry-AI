import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/api/poetry_ai.dart';
import 'package:poetry_ai/components/inline_adaptive_banner.dart';
import 'package:poetry_ai/pages/give_title.dart';
import 'package:poetry_ai/components/parallax_bg.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:provider/provider.dart';

class QuickMode extends StatefulWidget {
  const QuickMode({super.key, required this.features});
  final List<String> features;
  @override
  State<QuickMode> createState() => _QuickModeState();
}

class _QuickModeState extends State<QuickMode> {
  double topEleven = 0;
  double topTen = 0;
  double topNine = 0;
  double topEight = 0;
  double topSeven = 0;
  double topSix = 0;
  double topFive = 0;
  double topFour = 0;
  double topThree = 0;
  double topTwo = 0;
  double topOne = 0;
  late StreamSubscription<bool> keyboardSubscription;
  late List<bool> enabledStates = [true, false, false, false];
  List<bool> textFieldEnabledStates = [true, false, false, false];
  int focusedTextFieldIndex = 0;
  late List<FocusNode> focusNodes;
  late ScrollController _scrollController;
  late ScrollController lineController;
  bool isTextChanged = false;
  bool isListScrolling = false;
  bool expandTheVerseSpace = false;
  bool clickAnimation = false;
  bool isGenerationClicked = false;
  bool finished = false;
  bool isSelected = false;
  bool isAddAnotherStanza = false;
  bool isAnotherLineClicked = true;
  int selectedChipIndex = -1;
  String putLinesInTextfield = "";
  int totalTextfield = 4;
  int startingIndex = 0;
  int comparisionIndex = 3;
  List<String> generatedPoemLines = [];
  List<String> contextPreviousLines = [];
  List<String> contextNextLines = [];
  late List<TextEditingController> textControllers;
  bool isWideScreen = false;
  List<String> poemLines = [];
  List<String> reloadPoemLines = [];
  InterstitialAd? _interstitialAd;
  // TODO: replace this test ad unit with your own ad unit.
  final adInterUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

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

  @override
  void initState() {
    loadInterAd();
    textControllers = List.generate(4, (_) => TextEditingController());
    focusNodes = List.generate(4, (_) => FocusNode());
    super.initState();
    lineController = ScrollController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    for (var controller in textControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  final adsCounterStore = Hive.box('myAdsCounterStore');
  int currentAdsCounter = 1;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    return KeyboardVisibilityBuilder(
      builder: (p0, isKeyboardVisible) {
        if (isKeyboardVisible) {
          isTextChanged = true;
        }
        if (!isKeyboardVisible) {
          isTextChanged = false;
        }
        return Scaffold(
          body: SafeArea(
            child: NotificationListener(
              onNotification: (notif) {
                if (notif is ScrollUpdateNotification) {
                  if (notif.scrollDelta == null) return true;
                  setState(() {
                    if (!isTextChanged && !isListScrolling) {
                      topEleven -= notif.scrollDelta! / 1.7;
                      topTen -= notif.scrollDelta! / 1.9;
                      topNine -= notif.scrollDelta! / 1.8;
                      topEight -= notif.scrollDelta! / 1.7;
                      topSeven -= notif.scrollDelta! / 1.6;
                      topSix -= notif.scrollDelta! / 1.5;
                      topFive -= notif.scrollDelta! / 1.4;
                      topFour -= notif.scrollDelta! / 1.3;
                      topThree -= notif.scrollDelta! / 1.2;
                      topTwo -= notif.scrollDelta! / 1.2;
                      topOne -= notif.scrollDelta! / 1;
                    }
                  });
                }
                return true;
              },
              child: Stack(
                children: [
                  /// Paralax Background
                  ParallaxBackground(
                    top: topEleven,
                    asset: "assets/parallax/top-parallax-11-g.png",
                  ),
                  // ParallaxBackground(
                  //   top: topTen,
                  //   asset: "assets/parallax/top-parallax-10.png",
                  // ),
                  ParallaxBackground(
                    top: topNine,
                    asset: "assets/parallax/top-parallax-9-g.png",
                  ),
                  ParallaxBackground(
                    top: topEight,
                    asset: "assets/parallax/top-parallax-8-g.png",
                  ),
                  ParallaxBackground(
                    top: topSeven,
                    asset: "assets/parallax/top-parallax-7-g.png",
                  ),
                  ParallaxBackground(
                    top: topSix,
                    asset: "assets/parallax/top-parallax-6-g.png",
                  ),
                  ParallaxBackground(
                    top: topFive,
                    asset: "assets/parallax/top-parallax-5-g.png",
                  ),
                  ParallaxBackground(
                    top: topFour,
                    asset: "assets/parallax/top-parallax-4-g.png",
                  ),
                  ParallaxBackground(
                    top: topThree,
                    asset: "assets/parallax/top-parallax-3-g.png",
                  ),
                  ParallaxBackground(
                    top: topTwo,
                    asset: "assets/parallax/top-parallax-2-g.png",
                  ),
                  ParallaxBackground(
                    top: topOne,
                    asset: "assets/parallax/top-parallax-1-g.png",
                  ),
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: !isTextChanged
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3),
                        Container(
                          height: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width,
                          // color: const Color(0xff372d3b),
                          color: const Color(0xFF303030),
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "Verse By Verse",
                                  style: !isWideScreen
                                      ? TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily)
                                      : TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily),
                                ),
                              ).animate().fadeIn(
                                  duration: 400.ms, curve: Curves.easeIn),
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "Poem Structure",
                                  style: !isWideScreen
                                      ? TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily)
                                      : TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily),
                                ),
                              ).animate().fadeIn(
                                  duration: 800.ms, curve: Curves.easeIn),
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "${widget.features[0]}, ${widget.features[1]} syllable count, ${widget.features[2]}",
                                  style: !isWideScreen
                                      ? TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily)
                                      : TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily),
                                ),
                              ).animate().fadeIn(
                                  duration: 800.ms, curve: Curves.easeIn),
                              Expanded(
                                child: NotificationListener(
                                  onNotification: (scrollNotification) {
                                    if (scrollNotification
                                        is ScrollStartNotification) {
                                      setState(() {
                                        isListScrolling = true;
                                      });
                                    } else if (scrollNotification
                                        is ScrollEndNotification) {
                                      setState(() {
                                        isListScrolling = false;
                                      });
                                    }
                                    return true;
                                  },
                                  child: Scrollbar(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Column(
                                            children: List.generate(
                                                    totalTextfield, (index) {
                                              String previousLine = "";
                                              final isCurrentFieldEnabled =
                                                  textFieldEnabledStates[index];
                                              String hintText = "";
                                              if (isCurrentFieldEnabled) {
                                                if (index == startingIndex) {
                                                  hintText =
                                                      "Write your first line ...";
                                                } else {
                                                  hintText =
                                                      "Continue writing or generate suggestions";
                                                }
                                              } else {
                                                hintText = "Verse ${index + 1}";
                                              }
                                              if (index != startingIndex &&
                                                  isCurrentFieldEnabled &&
                                                  focusedTextFieldIndex ==
                                                      index) {
                                                if (putLinesInTextfield
                                                    .isNotEmpty) {
                                                  textControllers[index].text =
                                                      putLinesInTextfield;
                                                  putLinesInTextfield = "";
                                                }
                                              }
                                              for (TextEditingController controller
                                                  in textControllers) {
                                                if (controller.text.isEmpty) {
                                                  finished = false;
                                                  break; // No need to continue checking once an empty field is found
                                                } else {
                                                  finished = true;
                                                }
                                              }
                                              return Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                alignment: Alignment.topLeft,
                                                padding: const EdgeInsets.only(
                                                    left: 20.0,
                                                    right: 20.0,
                                                    top: 0,
                                                    bottom: 0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        focusNode:
                                                            focusNodes[index],
                                                        controller:
                                                            textControllers[
                                                                index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            isTextChanged =
                                                                true;
                                                            if (index <
                                                                comparisionIndex) {
                                                              textFieldEnabledStates[
                                                                  index +
                                                                      1] = true;
                                                            }
                                                          });
                                                          setState(() {
                                                            if (value.length >
                                                                20) {
                                                              expandTheVerseSpace =
                                                                  true;
                                                            }
                                                          });
                                                        },
                                                        maxLines: null,
                                                        enabled:
                                                            isCurrentFieldEnabled,
                                                        autofocus: false,
                                                        maxLength: 100,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        scrollController:
                                                            ScrollController(),
                                                        scrollPhysics:
                                                            const ClampingScrollPhysics(),
                                                        style: !isWideScreen
                                                            ? TextStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily)
                                                            : TextStyle(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily),
                                                        cursorColor:
                                                            Colors.white,
                                                        decoration:
                                                            InputDecoration(
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          labelText: hintText,
                                                          counterStyle: !isWideScreen
                                                              ? TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily)
                                                              : TextStyle(
                                                                  fontSize: 26,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily),
                                                          labelStyle: !isWideScreen
                                                              ? TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily)
                                                              : TextStyle(
                                                                  fontSize: 26,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily),
                                                          hintStyle: !isWideScreen
                                                              ? TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily)
                                                              : TextStyle(
                                                                  fontSize: 26,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily),
                                                        ),
                                                        onTap: () {
                                                          if (focusedTextFieldIndex ==
                                                              index - 1) {
                                                            isGenerationClicked =
                                                                false;
                                                            isAnotherLineClicked =
                                                                false;
                                                            generatedPoemLines
                                                                .clear();
                                                          }
                                                          setState(() {
                                                            focusedTextFieldIndex =
                                                                index;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    if (index !=
                                                            startingIndex &&
                                                        isCurrentFieldEnabled &&
                                                        focusedTextFieldIndex ==
                                                            index)
                                                      Container(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 20,
                                                                left: 0,
                                                                right: 0),
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF252525),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons
                                                                    .replay_outlined,
                                                                color: Colors
                                                                    .white),
                                                            onPressed: () {
                                                              int toAdsCount = context
                                                                  .read<
                                                                      AuthService>()
                                                                  .toAdsCount; // Use read() instead of watch()
                                                              final incrementCounter =
                                                                  context.read<
                                                                      AuthService>();
                                                              incrementCounter
                                                                  .incrementAdsCounter();
                                                              currentAdsCounter =
                                                                  toAdsCount;
                                                              adsCounterStore.put(
                                                                  'adsCounter',
                                                                  toAdsCount);

                                                              if (currentAdsCounter >=
                                                                  4) {
                                                                final reset =
                                                                    context.read<
                                                                        AuthService>();
                                                                reset
                                                                    .resetAdsCounter();
                                                                currentAdsCounter =
                                                                    toAdsCount;
                                                                adsCounterStore.put(
                                                                    'adsCounter',
                                                                    currentAdsCounter);
                                                                print(
                                                                    "SHOW ME THE ADS!");
                                                                _interstitialAd
                                                                    ?.show();
                                                                loadInterAd();
                                                              }
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              setState(() {
                                                                isAnotherLineClicked =
                                                                    true;
                                                                if (index <
                                                                        textFieldEnabledStates.length -
                                                                            1 &&
                                                                    !textFieldEnabledStates[
                                                                        index +
                                                                            1]) {
                                                                  textFieldEnabledStates[
                                                                          index +
                                                                              1] =
                                                                      true;
                                                                }
                                                              });
                                                              setState(() {
                                                                generatedPoemLines
                                                                    .clear();
                                                              });
                                                              setState(() {
                                                                isSelected =
                                                                    false;
                                                                selectedChipIndex =
                                                                    -1;
                                                              });
                                                              setState(() {
                                                                clickAnimation =
                                                                    !clickAnimation;
                                                              });
                                                              print(
                                                                  "Button pressed for text field $index");
                                                              setState(() {
                                                                poemLines
                                                                    .clear();
                                                                for (var controller
                                                                    in textControllers) {
                                                                  setState(() {
                                                                    poemLines.add(
                                                                        controller
                                                                            .text);
                                                                  });
                                                                }
                                                              });
                                                              setState(() {
                                                                previousLine =
                                                                    textControllers[
                                                                            index -
                                                                                1]
                                                                        .text;
                                                              });
                                                              setState(() {
                                                                contextPreviousLines
                                                                    .clear();
                                                                contextNextLines
                                                                    .clear();
                                                                int start =
                                                                    index - 4 >=
                                                                            0
                                                                        ? index -
                                                                            4
                                                                        : 0;
                                                                for (int i =
                                                                        start;
                                                                    i < index;
                                                                    i++) {
                                                                  if (poemLines[
                                                                          i]
                                                                      .isNotEmpty) {
                                                                    contextPreviousLines.add(
                                                                        poemLines[
                                                                            i]);
                                                                  }
                                                                }

                                                                for (int i =
                                                                        index +
                                                                            1;
                                                                    i <
                                                                        poemLines
                                                                            .length;
                                                                    i++) {
                                                                  if (poemLines[
                                                                          i]
                                                                      .isNotEmpty) {
                                                                    contextNextLines.add(
                                                                        poemLines[
                                                                            i]);
                                                                  }
                                                                }
                                                              });
                                                              setState(() {
                                                                isGenerationClicked =
                                                                    true;
                                                              });
                                                              PoetryAiTools()
                                                                  .callGenerateQuickLinesFunction(
                                                                      previousLine,
                                                                      contextPreviousLines,
                                                                      contextNextLines,
                                                                      widget
                                                                          .features)
                                                                  .then(
                                                                      (value) {
                                                                generatedPoemLines =
                                                                    [];
                                                                print(value);
                                                                List<String>
                                                                    responseLines =
                                                                    value.split(
                                                                        '\n');
                                                                for (String line
                                                                    in responseLines) {
                                                                  String
                                                                      trimmedLine =
                                                                      line.trim();

                                                                  if (trimmedLine
                                                                          .isNotEmpty &&
                                                                      ![
                                                                        ':',
                                                                        '-',
                                                                        '.',
                                                                        '"',
                                                                        '!'
                                                                      ].contains(
                                                                          trimmedLine)) {
                                                                    setState(
                                                                        () {
                                                                      generatedPoemLines
                                                                          .add(
                                                                              trimmedLine);
                                                                    });
                                                                  }
                                                                }
                                                              });
                                                            },
                                                          )
                                                              .animate(
                                                                  target:
                                                                      clickAnimation
                                                                          ? 1
                                                                          : 0)
                                                              .shake(
                                                                  duration:
                                                                      400.ms,
                                                                  rotation:
                                                                      0.5),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }).animate().fadeIn(
                                                  duration: 800.ms,
                                                  curve: Curves.easeIn,
                                                ),
                                          ),
                                          SizedBox(
                                            height: expandTheVerseSpace
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.5
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                            child: Column(
                                              children: [
                                                isGenerationClicked
                                                    ? Text(
                                                        "Here are a few suggestions ...",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily),
                                                      ).animate().fadeIn(
                                                        duration: 800.ms,
                                                        curve: Curves.easeIn)
                                                    : Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 20.0),
                                                        child: Text(
                                                          "Write poetry & generate suggestions ...",
                                                          style: !isWideScreen
                                                              ? TextStyle(
                                                                  fontSize: 24,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily)
                                                              : TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: GoogleFonts
                                                                          .ebGaramond()
                                                                      .fontFamily),
                                                        ),
                                                      ).animate().fadeIn(
                                                        duration: 800.ms,
                                                        curve: Curves.easeIn),
                                                Expanded(
                                                  child: Scrollbar(
                                                    child: generatedPoemLines
                                                                .isEmpty &&
                                                            isGenerationClicked
                                                        ? Visibility(
                                                            visible:
                                                                isAnotherLineClicked,
                                                            child: Lottie.asset(
                                                              'assets/loading.json',
                                                              width: 300,
                                                              height: 200,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          )
                                                        : ListView.builder(
                                                            itemCount:
                                                                generatedPoemLines
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              isSelected =
                                                                  selectedChipIndex ==
                                                                      index;
                                                              return ListTile(
                                                                leading: Icon(
                                                                  isSelected
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                                ),
                                                                title: Text(
                                                                  generatedPoemLines[
                                                                      index],
                                                                  style: !isWideScreen
                                                                      ? TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color: Colors
                                                                              .white,
                                                                          fontFamily: GoogleFonts.ebGaramond()
                                                                              .fontFamily)
                                                                      : TextStyle(
                                                                          fontSize:
                                                                              30,
                                                                          color: Colors
                                                                              .white,
                                                                          fontFamily:
                                                                              GoogleFonts.ebGaramond().fontFamily),
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    putLinesInTextfield =
                                                                        generatedPoemLines[
                                                                            index];
                                                                  });
                                                                  print(
                                                                      putLinesInTextfield);
                                                                  setState(() {
                                                                    selectedChipIndex =
                                                                        isSelected
                                                                            ? -1
                                                                            : index;
                                                                  });
                                                                },
                                                              );
                                                            },
                                                          )
                                                            .animate()
                                                            .slideX(
                                                                duration:
                                                                    500.ms)
                                                            .shimmer(
                                                                duration:
                                                                    5000.ms),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topRight,
                child: FloatingActionButton.small(
                  heroTag: 'go-back',
                  backgroundColor: const Color(0xFF303030),
                  child: const Icon(Icons.arrow_back,
                      size: 30, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InlineAdaptiveBannerAd(),
                        ));
                  },
                ),
              ),
              finished
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.bottomRight,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.06,
                              left: 20),
                          child: FloatingActionButton.extended(
                            heroTag: 'add-another-stanza',
                            label: Text(
                              "Add Another Stanza",
                              style: !isWideScreen
                                  ? TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily)
                                  : TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                            tooltip: "Add Another Stanza",
                            backgroundColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                isAddAnotherStanza = true;
                              });
                              for (var controller in textControllers) {
                                setState(() {
                                  reloadPoemLines.add(controller.text);
                                });
                              }
                              setState(() {
                                FocusManager.instance.primaryFocus?.unfocus();
                                totalTextfield = totalTextfield + 4;
                                startingIndex = startingIndex + totalTextfield;
                                comparisionIndex = comparisionIndex + 4;
                                textFieldEnabledStates.addAll(enabledStates);
                                textControllers = List.generate(totalTextfield,
                                    (_) => TextEditingController());
                                focusNodes = List.generate(
                                    totalTextfield, (_) => FocusNode());
                              });
                              setState(() {
                                for (int i = 0;
                                    i < reloadPoemLines.length;
                                    i++) {
                                  textControllers[i].text = reloadPoemLines[i];
                                }
                                reloadPoemLines.clear();
                              });
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.06),
                          child: FloatingActionButton.extended(
                            heroTag: 'finish',
                            label: Text(
                              "Finish",
                              style: !isWideScreen
                                  ? TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily)
                                  : TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                            tooltip: "Finish",
                            backgroundColor: Colors.white,
                            onPressed: () {
                              _interstitialAd?.show();
                              loadInterAd();
                              List<String> finishedPoemLines = [];
                              for (var controller in textControllers) {
                                setState(() {
                                  finishedPoemLines.add(controller.text);
                                });
                              }
                              String poem = finishedPoemLines.join('\n');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GiveTitle(poem: poem),
                                  ));
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        );
      },
    );
  }
}
