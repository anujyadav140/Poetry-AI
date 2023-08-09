import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/pages/parallax_bg.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:poetry_ai/services/ai/poetry_tools.dart';

class QuickMode extends StatefulWidget {
  const QuickMode({super.key});

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
  int selectedChipIndex = -1;
  String putLinesInTextfield = "";
  int totalTextfield = 4;
  int startingIndex = 0;
  int comparisionIndex = 3;
  List<String> generatedPoemLines = [];
  late List<TextEditingController> textControllers;

  List<String> poemLines = [];
  List<String> reloadPoemLines = [];
  @override
  void initState() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
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
                                  "Quatrain, 9 syllable count, ABAB rhyme pattern",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
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
                                              if (index !=
                                                      startingIndex && // Check if it's not the first text field
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
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: GoogleFonts
                                                                      .ebGaramond()
                                                                  .fontFamily,
                                                            ),
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
                                                          counterStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                          labelStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                          hintStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelSmall
                                                                  ?.copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        GoogleFonts.ebGaramond()
                                                                            .fontFamily,
                                                                  ),
                                                        ),
                                                        onTap: () {
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
                                                                isGenerationClicked =
                                                                    true;
                                                              });
                                                              // print(
                                                              //     previousLine);
                                                              // print(poemLines);
                                                              // PoetryTools()
                                                              //     .generateQuickLines(
                                                              //         previousLine,
                                                              //         poemLines)
                                                              //     .then(
                                                              //         (value) {
                                                              //   generatedPoemLines =
                                                              //       [];
                                                              //   print(value);
                                                              //   List<String>
                                                              //       responseLines =
                                                              //       value.split(
                                                              //           '\n');
                                                              //   for (String line
                                                              //       in responseLines) {
                                                              //     // Trim the line to remove leading and trailing whitespace
                                                              //     String
                                                              //         trimmedLine =
                                                              //         line.trim();

                                                              //     // Check if the trimmed line is not empty and not just a colon
                                                              //     if (trimmedLine
                                                              //             .isNotEmpty &&
                                                              //         trimmedLine !=
                                                              //             ":" &&
                                                              //         trimmedLine !=
                                                              //             "-" &&
                                                              //         trimmedLine !=
                                                              //             ".") {
                                                              //       setState(
                                                              //           () {
                                                              //         generatedPoemLines
                                                              //             .add(
                                                              //                 trimmedLine);
                                                              //       });
                                                              // }
                                                              // }
                                                              // });
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
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headlineSmall
                                                              ?.copyWith(
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
                                                        ? const SizedBox(
                                                            width: 200,
                                                            height: 15,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              semanticsLabel:
                                                                  "Loading ...",
                                                            ))
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
                                                              return ActionChip(
                                                                avatar: Icon(
                                                                  isSelected
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .red
                                                                      : null,
                                                                ),
                                                                label: Text(
                                                                    generatedPoemLines[
                                                                        index]),
                                                                onPressed: () {
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
                                                                    5000.ms)
                                                            .shimmer(),
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
                  backgroundColor: const Color(0xFF303030),
                  child: const Icon(Icons.arrow_back,
                      size: 25, color: Colors.white),
                  onPressed: () {},
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
                            label: Text(
                              "Add Another Stanza",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: const Color(0xFF303030),
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
                            label: Text(
                              "Finish",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: const Color(0xFF303030),
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                            tooltip: "Finish",
                            backgroundColor: Colors.white,
                            onPressed: () {
                              poemLines.clear();
                              for (var controller in textControllers) {
                                setState(() {
                                  poemLines.add(controller.text);
                                });
                              }
                              print(poemLines);
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
