import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/pages/parallax_bg.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener(
          onNotification: (notif) {
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
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
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
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                          ),
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
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                          ),
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
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.grey,
        child: const Icon(Icons.arrow_back, size: 25, color: Colors.black),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
