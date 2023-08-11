import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class TemplateForm extends StatefulWidget {
  const TemplateForm(
      {super.key, required this.description, required this.onFormSubmit});
  final String description;
  final Function(String, String, String) onFormSubmit;

  @override
  State<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  List<String> poeticForms = ["Quartrain", "Couplet", "Free Verse"];
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
    }
  };

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  void submitForm() {
    final selectedPoeticForm = poeticForms[selectedRadio];
    final selectedSyllableCount = dropdownSyllableCount;
    final selectedRhyme = dropdownRhyme;

    widget.onFormSubmit(
        selectedPoeticForm, selectedSyllableCount, selectedRhyme);
  }

  @override
  Widget build(BuildContext context) {
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.black,
                                fontFamily:
                                    GoogleFonts.ebGaramond().fontFamily),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Poetic Form:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily,
                                      fontWeight: FontWeight.bold),
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
                                  itemCount: poeticForms.length,
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
                                              setSelectedRadio(val!);
                                              submitForm();
                                            },
                                          ),
                                          Text(
                                            poeticForms[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    color: Colors.black,
                                                    fontFamily:
                                                        GoogleFonts.ebGaramond()
                                                            .fontFamily,
                                                    fontWeight: index ==
                                                            selectedRadio
                                                        ? FontWeight.bold
                                                        : FontWeight.normal),
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
                                      formDescriptions[
                                                  poeticForms[selectedRadio]]
                                              ?["Description"] ??
                                          "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Colors.black,
                                              fontFamily:
                                                  GoogleFonts.ebGaramond()
                                                      .fontFamily),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      formDescriptions[
                                                  poeticForms[selectedRadio]]
                                              ?["Sample Poem"] ??
                                          "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Colors.black,
                                            fontFamily: GoogleFonts.ebGaramond()
                                                .fontFamily,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Syllable Count:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "The number of syllables for each line of verse",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily,
                                      fontWeight: FontWeight.normal),
                            ),
                          ),
                          DropdownButton(
                            menuMaxHeight: 300.0,
                            items: syllableCountList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: dropdownSyllableCount,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Colors.black,
                                    fontFamily:
                                        GoogleFonts.ebGaramond().fontFamily,
                                    fontWeight: FontWeight.normal),
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
                        height: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Rhyme:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "The letters indicate which lines of the poem rhyme",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.ebGaramond().fontFamily,
                                      fontWeight: FontWeight.normal),
                            ),
                          ),
                          DropdownButton(
                            menuMaxHeight: 300.0,
                            items: rhymeSchemeList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Colors.black,
                                    fontFamily:
                                        GoogleFonts.ebGaramond().fontFamily,
                                    fontWeight: FontWeight.normal),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          WaveWidget(
            config: CustomConfig(
              // gradients: [
              //   [Colors.blue, Colors.blue.shade200],
              //   [Colors.blue.shade200, Colors.blue.shade100],
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
            size: const Size(double.infinity, 80.0),
          ),
        ],
      ),
    );
  }
}
