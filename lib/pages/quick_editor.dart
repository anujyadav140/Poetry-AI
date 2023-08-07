import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/pages/parallax_bg.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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
  bool isListViewContentScrolling = false;

  late StreamSubscription<bool> keyboardSubscription;
  final FocusNode globalFocus = FocusNode();
  final ScrollController _myListScrollController = ScrollController();
  final Duration _delayDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();

    print(
        'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (p0, isKeyboardVisible) {
        late bool isFocus = false;
        if (globalFocus.hasFocus) {
          isFocus = true;
        }
        if (!isKeyboardVisible) {
          globalFocus.unfocus();

          isFocus = false;
        }
        return Scaffold(
          body: SafeArea(
            child: NotificationListener(
              onNotification: (notif) {
                if (notif is ScrollUpdateNotification) {
                  if (notif.scrollDelta == null) return true;
                  if (!isKeyboardVisible && !isListViewContentScrolling) {
                    setState(() {
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
                    });
                  }
                  if (!isKeyboardVisible &&
                      (notif.metrics.axis == Axis.vertical) &&
                      (notif.metrics.maxScrollExtent ==
                          _myListScrollController.position.maxScrollExtent) &&
                      (notif.metrics.minScrollExtent ==
                          _myListScrollController.position.minScrollExtent)) {
                    setState(() {
                      isListViewContentScrolling = true;
                    });
                  } else {
                    setState(() {
                      isListViewContentScrolling = false;
                    });
                  }
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
                    physics: isFocus
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3),
                        Container(
                          height: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).size.height * 0.15,
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
                                  "Verse By Verse Editor",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
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
                                      .titleLarge
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
                                      .titleMedium
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
                                              .fontFamily),
                                ),
                              ).animate().fadeIn(
                                  duration: 800.ms, curve: Curves.easeIn),
                              const SizedBox(
                                height: 25,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 10,
                                  scrollDirection: Axis.vertical,
                                  controller: _myListScrollController,
                                  itemBuilder: (context, index) {
                                    final textFocus = FocusNode();
                                    final textEditingController =
                                        TextEditingController();
                                    return Container(
                                      height: 100,
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      child: TextField(
                                        // maxLines: null,
                                        autofocus: false,
                                        focusNode: textFocus,
                                        enableInteractiveSelection: false,
                                        controller: textEditingController,
                                        scrollController: ScrollController(),
                                        scrollPhysics:
                                            const ClampingScrollPhysics(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Colors.white,
                                                fontFamily:
                                                    GoogleFonts.ebGaramond()
                                                        .fontFamily),
                                        cursorColor: Colors.white,
                                        decoration: const InputDecoration(
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          // labelText:
                                          //     "Write your first line ...",
                                          hintText: "Write your first line ...",
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          hintStyle:
                                              TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ).animate().fadeIn(
                                        duration: 1000.ms,
                                        curve: Curves.easeIn);
                                  },
                                ),
                              )
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
          floatingActionButton: FloatingActionButton.small(
            backgroundColor: const Color(0xFF303030),
            child: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
            onPressed: () {},
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        );
      },
    );
  }
}
