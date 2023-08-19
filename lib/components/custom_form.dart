import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class CustomForm extends StatefulWidget {
  const CustomForm(
      {super.key, required this.description, required this.onFormSubmit});
  final String description;
  final Function(String, String, String, String) onFormSubmit;
  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  bool isCustom = true;
  bool isCouplet = false;
  bool isHaiku = false;
  bool isBlankVerse = false;
  List<String> customPoeticForms = [
    "Custom Poetry",
    "Quartrain",
    "Couplet",
    "Free Verse",
    "Haiku",
    "Sonnet",
    "Blank Verse",
    "Limerick",
    "Ballad",
  ];
  List<String> customMeterStyle = [
    "Iamb",
    "Trochee",
    "Anapest",
    "Dactyl",
    "Spondee",
    "Pyrrhic",
    "Amphibrach",
  ];
  int selectedRadio = 0;
  int selectedFootRadio = 0;
  final List<String> rhymeSchemeList = <String>[
    'ABAB',
    'AABB',
    'ABBA',
    'ABCB',
    'No Rhyme'
  ];
  String dropdownRhyme = "ABAB";

  final List<String> syllableCountList = <String>[
    'Any',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  String dropdownSyllableCount = "10";

  Map<String, Map<String, String>> formDescriptions = {
    "Custom Poetry": {
      "Description":
          "Select your own custom meter, rhyme scheme and syllable counts, make something unique!",
    },
    "Quartrain": {
      "Description":
          "Quatrain is a poem in which its stanzas are composed of 4 lines of verse, often with a rhyming schema.",
      "Sample Poem":
          "Love is the dear heart amid the flowers,\nSweet as a light in a beating meadow,\nHurried by her from her earthly hour,\nHopeless the raging tempest of her woe."
    },
    "Couplet": {
      "Description":
          "Couplet is a poem in which its stanzas are composed of 2 rhyming lines of verse.",
      "Sample Poem":
          "Thou shalt not win the music of thy life,\nAn infinite within the world's mad strife.\n An infinite conflict, a shifting stream,\nLove after a cloud, like a baleful dream."
    },
    "Free Verse": {
      "Description":
          "Free verse is a poem that is free of rules, such as no distinct rhyme pattern.",
      "Sample Poem":
          "I celebrate myself, and sing myself,\nAnd what I assume you shall assume,\nFor every atom belonging to me as good belongs to you."
    },
    "Haiku": {
      "Description":
          "Haiku is a traditional form of Japanese poetry consisting of three lines with a syllable pattern of 5-7-5.",
      "Sample Poem":
          "An old silent pond...\nA frog jumps into the pond—\nSplash! Silence again."
    },
    "Sonnet": {
      "Description":
          "Sonnet is a 14-line poem, typically with a specific rhyme scheme, often exploring themes of love.",
      "Sample Poem":
          "Shall I compare thee to a summer's day?\nThou art more lovely and more temperate:\nRough winds do shake the darling buds of May,"
    },
    "Blank Verse": {
      "Description":
          "Blank verse is a type of poetry with a regular meter but no fixed rhyme scheme.",
      "Sample Poem":
          "To be or not to be, that is the question:\nWhether 'tis nobler in the mind to suffer\nThe slings and arrows of outrageous fortune,"
    },
    "Limerick": {
      "Description":
          "Limerick is a humorous poem with a specific AABBA rhyme scheme.",
      "Sample Poem":
          "There once was a man from Peru,\nWho dreamt he was eating his shoe.\nHe awoke with a fright,\nIn the middle of the night,\nTo find that his dream had come true!"
    },
    "Ballad": {
      "Description":
          "Ballad is a narrative poem that often tells a story of tragedy or romance.",
      "Sample Poem":
          "Bonny Barbara Allan,\nHer love was my pride and joy,\nAnd slowly, slowly rase she up,\nAnd slowly she rase she up,\nAnd slowly she rase she up."
    },
  };
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  setSelectedFootRadio(int val) {
    setState(() {
      selectedFootRadio = val;
    });
  }

  void submitForm() {
    final selectedPoeticForm = customPoeticForms[selectedRadio];
    final selectedFootStyle = customMeterStyle[selectedFootRadio];
    String selectedSyllableCount = dropdownSyllableCount;
    String selectedRhyme = dropdownRhyme;
    print(selectedPoeticForm);
    print(selectedFootStyle);
    print(selectedSyllableCount);
    print(selectedRhyme);
    if (isCouplet) {
      selectedRhyme = "AABB";
    }
    if (isHaiku) {
      selectedSyllableCount = "Haiku Syllable Pattern of 5-7-5";
      selectedRhyme = "No Rhyme";
    }
    if (isBlankVerse) {
      selectedRhyme =
          "No Rhyme, Blank Verse has no specific rhyme scheme pattern";
    }
    widget.onFormSubmit(selectedPoeticForm, selectedFootStyle,
        selectedSyllableCount, selectedRhyme);
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = false;
    bool isLongScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    if (MediaQuery.of(context).size.height >= 1000) {
      isLongScreen = true;
    }
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.description,
                        style: !isWideScreen
                            ? TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: GoogleFonts.ebGaramond().fontFamily)
                            : TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                                fontFamily:
                                    GoogleFonts.ebGaramond().fontFamily),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Poetic Form:",
                              style: TextStyle(
                                  fontSize: !isWideScreen ? 18 : 26,
                                  color: Colors.black,
                                  fontFamily:
                                      GoogleFonts.ebGaramond().fontFamily),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: customPoeticForms.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Column(
                                        children: [
                                          Radio(
                                            fillColor:
                                                const MaterialStatePropertyAll(
                                                    Colors.black),
                                            value: index,
                                            groupValue: selectedRadio,
                                            onChanged: (val) {
                                              if (index == 0) {
                                                setState(() {
                                                  isCustom = true;
                                                });
                                              } else {
                                                setState(() {
                                                  isCustom = false;
                                                });
                                              }
                                              if (index == 1) {
                                                setState(() {
                                                  isCouplet =
                                                      true; // Set isCouplet to true
                                                });
                                              } else {
                                                setState(() {
                                                  isCouplet =
                                                      false; // Set isCouplet to false
                                                });
                                              }
                                              if (index == 3) {
                                                setState(() {
                                                  isHaiku = true;
                                                });
                                              } else {
                                                setState(() {
                                                  isHaiku = false;
                                                });
                                              }
                                              if (index == 5) {
                                                setState(() {
                                                  isBlankVerse = true;
                                                });
                                              } else {
                                                setState(() {
                                                  isBlankVerse = false;
                                                });
                                              }
                                              setSelectedRadio(val!);
                                              submitForm();
                                            },
                                          ),
                                          Text(
                                            customPoeticForms[index],
                                            style: !isWideScreen
                                                ? TextStyle(
                                                    fontWeight:
                                                        index == selectedRadio
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        GoogleFonts.ebGaramond()
                                                            .fontFamily)
                                                : TextStyle(
                                                    fontWeight:
                                                        index == selectedRadio
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    fontSize: 26,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        GoogleFonts.ebGaramond()
                                                            .fontFamily),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible: selectedRadio == selectedRadio,
                                child: Column(
                                  children: [
                                    Text(
                                      formDescriptions[customPoeticForms[
                                              selectedRadio]]?["Description"] ??
                                          "",
                                      style: !isWideScreen
                                          ? TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontFamily:
                                                  GoogleFonts.ebGaramond()
                                                      .fontFamily)
                                          : TextStyle(
                                              fontSize: 26,
                                              color: Colors.black,
                                              fontFamily:
                                                  GoogleFonts.ebGaramond()
                                                      .fontFamily),
                                    ),
                                    const SizedBox(height: 10),
                                    Visibility(
                                      visible: !isCustom,
                                      child: Text(
                                        formDescriptions[customPoeticForms[
                                                    selectedRadio]]
                                                ?["Sample Poem"] ??
                                            "",
                                        style: !isWideScreen
                                            ? TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily:
                                                    GoogleFonts.ebGaramond()
                                                        .fontFamily)
                                            : TextStyle(
                                                fontSize: 26,
                                                color: Colors.black,
                                                fontFamily:
                                                    GoogleFonts.ebGaramond()
                                                        .fontFamily),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Visibility(
                                      visible: isCustom,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Meter Foot Style:",
                                              style: TextStyle(
                                                  fontSize:
                                                      !isWideScreen ? 18 : 26,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      GoogleFonts.ebGaramond()
                                                          .fontFamily),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  customMeterStyle.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Column(
                                                    children: [
                                                      Radio(
                                                        fillColor:
                                                            const MaterialStatePropertyAll(
                                                                Colors.black),
                                                        value: index,
                                                        groupValue:
                                                            selectedFootRadio,
                                                        onChanged: (val) {
                                                          setSelectedFootRadio(
                                                              val!);
                                                          submitForm();
                                                        },
                                                      ),
                                                      Text(
                                                        customMeterStyle[index],
                                                        style: !isWideScreen
                                                            ? TextStyle(
                                                                fontWeight: index ==
                                                                        selectedFootRadio
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily)
                                                            : TextStyle(
                                                                fontWeight: index ==
                                                                        selectedFootRadio
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                                fontSize: 26,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Visibility(
                        visible: !isHaiku,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Syllable Count:",
                                style: !isWideScreen
                                    ? TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily:
                                            GoogleFonts.ebGaramond().fontFamily)
                                    : TextStyle(
                                        fontSize: 26,
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "The number of syllables for each line of verse",
                                style: !isWideScreen
                                    ? TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily:
                                            GoogleFonts.ebGaramond().fontFamily)
                                    : TextStyle(
                                        fontSize: 26,
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                              ),
                            ),
                            DropdownButton(
                              menuMaxHeight: 300.0,
                              items: syllableCountList
                                  .map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: !isWideScreen ? 18 : 26,
                                        color: Colors.black,
                                        fontFamily:
                                            GoogleFonts.ebGaramond().fontFamily,
                                        fontWeight: value ==
                                                dropdownSyllableCount
                                            ? FontWeight.bold
                                            : FontWeight
                                                .normal, // Adjust font weight here
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                              value: dropdownSyllableCount,
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownSyllableCount = value!;
                                  submitForm();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Visibility(
                        visible: !isCouplet && !isHaiku && !isBlankVerse,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Rhyme:",
                                style: !isWideScreen
                                    ? TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily:
                                            GoogleFonts.ebGaramond().fontFamily)
                                    : TextStyle(
                                        fontSize: 26,
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "The letters indicate which lines of the poem rhyme",
                                style: !isWideScreen
                                    ? TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily:
                                            GoogleFonts.ebGaramond().fontFamily)
                                    : TextStyle(
                                        fontSize: 26,
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                              ),
                            ),
                            DropdownButton(
                              menuMaxHeight: 300.0,
                              items: rhymeSchemeList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: !isWideScreen ? 18 : 26,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily,
                                      fontWeight: value == dropdownRhyme
                                          ? FontWeight.bold
                                          : FontWeight
                                              .normal, // Adjust font weight here
                                    ),
                                  ),
                                );
                              }).toList(),
                              style: !isWideScreen
                                  ? TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily)
                                  : TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                              value: dropdownRhyme,
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownRhyme = value!;
                                  submitForm();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          isLongScreen
              ? SizedBox(height: MediaQuery.of(context).size.height * 0.1)
              : Container(),
          WaveWidget(
            config: CustomConfig(
              // gradients: [
              //   [Colors.blue, Colors.blue.shade180],
              //   [Colors.blue.shade180, Colors.blue.shade100],
              // ],
              gradients: [
                [Colors.grey, Colors.grey.shade200],
                [Colors.grey.shade200, Colors.grey.shade300],
              ],
              durations: [3500, 5000],
              heightPercentages: [0.05, 0.1],
            ),
            waveAmplitude: 0,
            backgroundColor: Colors.transparent,
            size: !isLongScreen
                ? Size(
                    double.infinity, MediaQuery.of(context).size.height * 0.2)
                : Size(
                    double.infinity, MediaQuery.of(context).size.height * 0.3),
          ),
        ],
      ),
    );
  }
}
