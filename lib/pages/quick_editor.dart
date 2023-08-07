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

  late StreamSubscription<bool> keyboardSubscription;
  late ScrollController _scrollController;
  bool _isScrolledToBottom = false;
  bool _isAnimatingToBottom = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // Add a listener to the scroll controller to track the scroll position
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Dispose of the scroll controller to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  // Callback function to be executed whenever the user scrolls
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // The user has reached the bottom of the page
      setState(() {
        _isScrolledToBottom = true;
      });
    } else {
      // The user is not at the bottom of the page
      setState(() {
        _isScrolledToBottom = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (p0, isKeyboardVisible) {
        return Scaffold(
          body: SafeArea(
            child: NotificationListener(
              onNotification: (notif) {
                if (!_isAnimatingToBottom && isKeyboardVisible) {
                  // Animate to the bottom of the page
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );

                  // Mark the animation as started
                  setState(() {
                    _isAnimatingToBottom = true;
                  });
                }
                if (notif is ScrollUpdateNotification) {
                  if (notif.scrollDelta == null) return true;
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
                    physics: _isAnimatingToBottom
                        ? const NeverScrollableScrollPhysics()
                        : !isKeyboardVisible
                            ? const ClampingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
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
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: TextField(
                                  maxLines: null,
                                  autofocus: false,
                                  maxLength: 100,
                                  textCapitalization: TextCapitalization.words,
                                  scrollController: ScrollController(),
                                  scrollPhysics: isKeyboardVisible
                                      ? const NeverScrollableScrollPhysics()
                                      : const ClampingScrollPhysics(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
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
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: TextField(
                                  maxLines: null,
                                  autofocus: false,
                                  maxLength: 100,
                                  textCapitalization: TextCapitalization.words,
                                  scrollController: ScrollController(),
                                  scrollPhysics: isKeyboardVisible
                                      ? const NeverScrollableScrollPhysics()
                                      : const ClampingScrollPhysics(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
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
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: TextField(
                                  maxLines: null,
                                  autofocus: false,
                                  maxLength: 100,
                                  textCapitalization: TextCapitalization.words,
                                  scrollController: ScrollController(),
                                  scrollPhysics: isKeyboardVisible
                                      ? const NeverScrollableScrollPhysics()
                                      : const ClampingScrollPhysics(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontFamily: GoogleFonts.ebGaramond()
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
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white),
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
