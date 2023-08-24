import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class TemplateForm extends StatefulWidget {
  const TemplateForm({
    super.key,
    required this.description,
    required this.onFormSubmit,
  });
  final String description;
  final Function(String, String, String) onFormSubmit;
  @override
  State<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  final globalThemeBox = Hive.box('myThemeBox');
  bool isCouplet = false;
  bool isFreeVerse = false;
  List<String> quickPoeticForms = ["Quartrain", "Couplet", "Free Verse"];
  int selectedRadio = 0;
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
  };
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  void submitForm() {
    final selectedPoeticForm = quickPoeticForms[selectedRadio];
    final selectedSyllableCount = dropdownSyllableCount;
    String selectedRhyme = dropdownRhyme;
    if (isCouplet) {
      selectedRhyme = "AABB";
    }
    if (isFreeVerse) {
      selectedRhyme =
          "No Rhyme, Free Verse has no specific rhyme scheme pattern";
    }
    widget.onFormSubmit(
        selectedPoeticForm, selectedSyllableCount, selectedRhyme);
  }

  List<List<Color>>? gradients = [];
  @override
  Widget build(BuildContext context) {
    final themeValue = globalThemeBox.get('theme') ?? 'Classic';
    if (themeValue == "Classic") {
      setState(() {
        gradients = [
          [Colors.grey, Colors.grey.shade200],
          [Colors.grey.shade200, Colors.grey.shade300],
        ];
      });
    } else if (themeValue == "Purple") {
      setState(() {
        gradients = [
          [Colors.purple, Colors.purple.shade200],
          [Colors.purple.shade200, Colors.purple.shade300],
        ];
      });
    } else if (themeValue == "Green") {
      setState(() {
        gradients = [
          [Colors.green, Colors.green.shade200],
          [Colors.green.shade200, Colors.green.shade300],
        ];
      });
    }
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
                                  itemCount: quickPoeticForms.length,
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
                                              if (index == 1) {
                                                setState(() {
                                                  isCouplet = true;
                                                });
                                              } else {
                                                setState(() {
                                                  isCouplet = false;
                                                });
                                              }
                                              if (index == 2) {
                                                setState(() {
                                                  isFreeVerse = true;
                                                });
                                              } else {
                                                setState(() {
                                                  isFreeVerse = false;
                                                });
                                              }
                                              setSelectedRadio(val!);
                                              submitForm();
                                            },
                                          ),
                                          Text(
                                            quickPoeticForms[index],
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
                                      formDescriptions[quickPoeticForms[
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
                                    Text(
                                      formDescriptions[quickPoeticForms[
                                              selectedRadio]]?["Sample Poem"] ??
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
                      Column(
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
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
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
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily),
                            ),
                          ),
                          DropdownButton(
                            menuMaxHeight: 300.0,
                            items:
                                syllableCountList.map<DropdownMenuItem<String>>(
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
                                      fontWeight: value == dropdownSyllableCount
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
                      const SizedBox(
                        height: 18,
                      ),
                      Visibility(
                        visible: !isCouplet && !isFreeVerse,
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
              gradients: gradients,
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
