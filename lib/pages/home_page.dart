import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/components/custom_form.dart';
import 'package:poetry_ai/components/quick_form.dart';
import 'package:poetry_ai/components/template_card.dart';
import 'package:poetry_ai/pages/editor.dart';
import 'package:poetry_ai/pages/quick_editor.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  final RateMyApp rateMyApp;
  const HomePage({super.key, required this.rateMyApp});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Poem {
  String title;
  String type;
  List<String> features;
  String poetry;
  String meter;
  List<String> bookmarks;

  Poem(this.title, this.type, this.features, this.poetry, this.meter,
      this.bookmarks);
}

class CustomPoem {
  String form;
  String syllables;
  String rhymes;

  CustomPoem(this.form, this.syllables, this.rhymes);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentPoemIndex = -1;
  late AnimationController _controller;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String user = "";
  String setPoemType = "";
  String setPoemMeter = "";
  ScrollController scrollController = ScrollController();
  final globalThemeBox = Hive.box('myThemeBox');
  final poemListBox = Hive.box('myPoemBox');
  final poemListIndexBox = Hive.box('myPoemListIndexBox');
  final customPoemListBox = Hive.box('myCustomPoemBox');
  PoetryType poetryTypeName = PoetryType("", "", [""], [""], "");
  bool isTemplateClicked = false;
  bool isPoemListNotEmpty = true;
  List<String> features = [""];
  List<String> icons = [""];
  int selectedCustomTemplateIndex = -1;
  int selectedPredefinedTemplateIndex = -1;
  List<dynamic>? existingPoemList = [];
  bool isCustomTemplate = false;
  bool isWideScreen = false;
  List<String> customPoetryMode = ["Quick Poetry", "Custom Poetry"];
  List<String> customPoetryDescription = [
    "Write poetry very quickly, just select a poem template; Decide what kind of poem you would like to write. Write poetry Verse By Verse and get suggestions by AI.",
    "Design your own custom template to follow and write your own poem using a word editor. Use AI tools to get the most out of the experience."
  ];
  String selectedDescription = "";
  List<String> customPoetryTemplateSelection = ["Quartrain", "10", "ABAB"];
  @override
  void initState() {
    currentPoemIndex = poemListIndexBox.get('poemIndex') ?? -1;
    //FIREBASE FUNCTIONALITY CODE
    // if (firebaseAuth.currentUser?.displayName != null) {
    //   user = firebaseAuth.currentUser!.displayName!;
    // } else {
    //   user = firebaseAuth.currentUser!.email!;
    //   String email = user;
    //   RegExp regex = RegExp(r"^(.+)@.*$");
    //   String username = regex.firstMatch(email)?.group(1) ?? email;
    //   user = username;
    // }
    globalThemeBox.get('theme');
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(seconds: 10),
      upperBound: 1,
      lowerBound: -1,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setGlobalTheme(String theme) {
    globalThemeBox.put('theme', theme);
    print(globalThemeBox.get('theme'));
  }

  void deleteGlobalTheme() {
    globalThemeBox.delete('theme');
    print("Deleted");
  }

  List<String> themeList = [
    "Classic",
    "Green",
    "Purple",
  ];

  void setPoemList(String poemTitle, String poemType, List<String> poemFeatures,
      String poetry, String meter, List<String> bookmarks) {
    var poem = Poem(
      poemTitle,
      poemType,
      poemFeatures,
      poetry,
      meter,
      bookmarks,
    );

    poemListBox.add({
      'title': poem.title,
      'type': poem.type,
      'features': poem.features,
      'poem': poem.poetry,
      'meter': poem.meter,
      'bookmarks': poem.bookmarks
    });
  }

  void setCustomPoemList(String poeticForm, String syllables, String rhymes) {
    var customPoem = CustomPoem(poeticForm, syllables, rhymes);

    customPoemListBox.add({
      'form': customPoem.form,
      'syllables': customPoem.syllables,
      'rhymes': customPoem.rhymes,
    });
  }

  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pick a theme ...',
            style: TextStyle(
                fontSize: !isWideScreen ? 20 : 26,
                color: Colors.black,
                fontFamily: GoogleFonts.ebGaramond().fontFamily),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: themeList.map((theme) {
                return ListTile(
                  title: Text(
                    theme,
                    style: TextStyle(
                        fontSize: !isWideScreen ? 20 : 26,
                        color: Colors.black,
                        fontFamily: GoogleFonts.ebGaramond().fontFamily),
                  ),
                  onTap: () {
                    if (theme == "Purple") {
                      setState(() {
                        setGlobalTheme(theme);
                      });
                      print("Purple Theme Selected");
                    } else if (theme == "Green") {
                      setState(() {
                        setGlobalTheme(theme);
                      });
                      print("Green Theme Selected");
                    } else if (theme == "Classic") {
                      setState(() {
                        setGlobalTheme(theme);
                      });
                      print("Classic Theme Selected");
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  bool isCustom = false;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    final themeValue = globalThemeBox.get('theme') ?? 'Classic';
    //FIREBASE FUNCTIONALITY CODE
    // void logout() async {
    //   //show loading
    //   showDialog(
    //     context: context,
    //     builder: (context) {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     },
    //   );
    //   AuthService().logout();
    //   //pop the loading
    //   Navigator.pop(context);
    // }

    void onTapCustomTemplate(int index) {
      print(index);
      if (index == 1) {
        setState(() {
          isCustom = true;
        });
      } else if (index == 0) {
        setState(() {
          isCustom = false;
        });
      }
      setState(() {
        // Check if the same custom template is clicked again
        if (selectedCustomTemplateIndex == index) {
          selectedCustomTemplateIndex = -1;
          isCustomTemplate = false;
        } else {
          // Deselect the previous custom template if one was selected
          if (selectedCustomTemplateIndex != -1) {
            selectedCustomTemplateIndex = -1;
            isCustomTemplate = false;
          }
          // Select the new custom template
          selectedCustomTemplateIndex = index;
          isCustomTemplate = true;

          // Deselect any predefined template if one was selected
          selectedPredefinedTemplateIndex = -1;
          isTemplateClicked = false;
        }
        selectedDescription = customPoetryDescription[index];
      });
    }

    void onTapTemplate(int index) {
      setState(() {
        // Check if the same predefined template is clicked again
        if (selectedPredefinedTemplateIndex == index) {
          selectedPredefinedTemplateIndex = -1;
          isTemplateClicked = false;
        } else {
          // Deselect the previous predefined template if one was selected
          if (selectedPredefinedTemplateIndex != -1) {
            selectedPredefinedTemplateIndex = -1;
            isTemplateClicked = false;
          }
          // Select the new predefined template
          selectedPredefinedTemplateIndex = index;
          isTemplateClicked = true;

          // Deselect the Quick Poetry Template Form
          selectedCustomTemplateIndex = -1;
          isCustomTemplate = false;
        }

        poetryTypeName = PoetryTypesData.getPoetryTypeByName(
          PoetryTypesData.poetryTypes[index].name,
        );
        setPoemType = PoetryTypesData.poetryTypes[index].name;
        setPoemMeter = PoetryTypesData.poetryTypes[index].metre;
        features = PoetryTypesData.getFeaturesByName(poetryTypeName.name);
        icons = PoetryTypesData.getIconsByName(poetryTypeName.name);
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          //FIREBBASE FUNCTIONALITY CODE
          // "Welcome, $user!",
          "Welcome, Dear Poet",
          maxLines: 4,
          style: TextStyle(
              fontSize: !isWideScreen ? 20 : 26,
              color: Colors.black,
              fontFamily: GoogleFonts.ebGaramond().fontFamily),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          PopupMenuButton(
            icon: Icon(
              size: 30,
              Icons.menu,
              color: ColorTheme.text(themeValue),
            ),
            onSelected: (value) {
              if (value == 'themes') {
                showThemeDialog(context);
              }
              //FIREBASE FUNCTIONALITY CODE
              // else if (value == 'logout') {
              //   logout();
              // }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'themes',
                child: ListTile(
                  leading: const Icon(Icons.palette),
                  title: Text(
                    "Themes",
                    style: TextStyle(
                        fontSize: !isWideScreen ? 20 : 26,
                        color: Colors.black,
                        fontFamily: GoogleFonts.ebGaramond().fontFamily),
                  ),
                ),
              ),
              //FIREBASE FUNCTIONALITY CODE
              // const PopupMenuItem(
              //   value: 'logout',
              //   child: ListTile(
              //     leading: Icon(Icons.logout),
              //     title: Text("Logout"),
              //   ),
              // ),
            ],
          )
        ],
      ),
      backgroundColor: ColorTheme.accent(themeValue),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (int i = 0; i < customPoetryMode.length; i++)
                  Template(
                    templateBoxColor: ColorTheme.primary(themeValue),
                    templateSplashColor: ColorTheme.secondary(themeValue),
                    templateFontColor: ColorTheme.accent(themeValue),
                    templateUnderlineColor: ColorTheme.accent(themeValue),
                    name: customPoetryMode[i],
                    description: customPoetryDescription[i],
                    onTap: () => onTapCustomTemplate(i),
                    isSelected: selectedCustomTemplateIndex == i,
                  ),
                for (int j = 0; j < PoetryTypesData.poetryTypes.length; j++)
                  Template(
                    templateBoxColor: ColorTheme.primary(themeValue),
                    templateSplashColor: ColorTheme.secondary(themeValue),
                    templateUnderlineColor: ColorTheme.accent(themeValue),
                    templateFontColor: ColorTheme.text(themeValue),
                    name: PoetryTypesData.poetryTypes[j].name,
                    description: PoetryTypesData.poetryTypes[j].description,
                    onTap: () => onTapTemplate(j),
                    isSelected: selectedPredefinedTemplateIndex == j,
                  ),
              ]),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    color: ColorTheme.secondary(themeValue),
                    child: isCustomTemplate
                        ? Visibility(
                            visible: isCustomTemplate,
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                  child: isCustom
                                      ? CustomForm(
                                          description: selectedDescription,
                                          onFormSubmit: (String poeticForm,
                                              String syllables,
                                              String rhyme,
                                              String footStyle) {
                                            customPoetryTemplateSelection
                                                .clear();
                                            customPoetryTemplateSelection
                                                .insert(0, poeticForm);
                                            customPoetryTemplateSelection
                                                .insert(1, syllables);
                                            customPoetryTemplateSelection
                                                .insert(2, rhyme);
                                            customPoetryTemplateSelection
                                                .insert(3, footStyle);
                                          },
                                        )
                                      : TemplateForm(
                                          description: selectedDescription,
                                          onFormSubmit: (String poeticForm,
                                              String syllables, String rhyme) {
                                            customPoetryTemplateSelection
                                                .clear();
                                            customPoetryTemplateSelection
                                                .insert(0, poeticForm);
                                            customPoetryTemplateSelection
                                                .insert(1, syllables);
                                            customPoetryTemplateSelection
                                                .insert(2, rhyme);
                                          },
                                        )),
                            ),
                          )
                        : isTemplateClicked
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            poetryTypeName.description,
                                            style: TextStyle(
                                                fontSize:
                                                    !isWideScreen ? 20 : 26,
                                                color: Colors.black,
                                                fontFamily:
                                                    GoogleFonts.ebGaramond()
                                                        .fontFamily),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Features for ${poetryTypeName.name}:",
                                            style: TextStyle(
                                                fontSize:
                                                    !isWideScreen ? 20 : 26,
                                                color: Colors.black,
                                                fontFamily:
                                                    GoogleFonts.ebGaramond()
                                                        .fontFamily,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Scrollbar(
                                        controller: scrollController,
                                        thumbVisibility: true,
                                        child: ListView.builder(
                                          controller: scrollController,
                                          itemCount: features.length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: Image.asset(
                                                        icons[index]),
                                                  ),
                                                  title: Text(
                                                    features[index],
                                                    style: !isWideScreen
                                                        ? TextStyle(
                                                            fontSize: 19,
                                                            color: Colors.black,
                                                            fontFamily: GoogleFonts
                                                                    .ebGaramond()
                                                                .fontFamily)
                                                        : TextStyle(
                                                            fontSize: 25,
                                                            color: Colors.black,
                                                            fontFamily: GoogleFonts
                                                                    .ebGaramond()
                                                                .fontFamily),
                                                  ),
                                                ),
                                                if (index !=
                                                    features.length - 1)
                                                  const Divider(
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : poemListBox.isNotEmpty
                                ? Scrollbar(
                                    controller: scrollController,
                                    thumbVisibility: true,
                                    thickness: 5.0,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: poemListBox.length,
                                      itemBuilder: (context, index) {
                                        var poemData = poemListBox.getAt(index)
                                            as Map<dynamic, dynamic>;
                                        String poemTitle =
                                            poemData['title'] as String;
                                        String poemForm =
                                            poemData['type'] as String;
                                        List<String> poemFeatures =
                                            poemData['features']
                                                as List<String>;
                                        String poemMeter =
                                            poemData['meter'] as String;
                                        return Slidable(
                                          key: const ValueKey(0),
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              //FUTURE FUNCTIONALITY CODE
                                              // SlidableAction(
                                              //   onPressed: (context) {},
                                              //   backgroundColor:
                                              //       const Color(0xFF21B7CA),
                                              //   foregroundColor: Colors.white,
                                              //   icon: Icons.share,
                                              //   label: 'Share',
                                              // ),
                                              SlidableAction(
                                                onPressed: (context) {
                                                  setState(() {
                                                    poemListBox.deleteAt(index);
                                                    currentPoemIndex--;
                                                    poemListIndexBox.put(
                                                        'poemIndex',
                                                        currentPoemIndex);
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          ColorTheme.accent(
                                                              themeValue),
                                                      content: Text(
                                                        '$poemTitle deleted.',
                                                        style: !isWideScreen
                                                            ? TextStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily)
                                                            : TextStyle(
                                                                fontSize: 26,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily: GoogleFonts
                                                                        .ebGaramond()
                                                                    .fontFamily),
                                                      ),
                                                      action: SnackBarAction(
                                                        backgroundColor:
                                                            ColorTheme.primary(
                                                                themeValue),
                                                        label: 'Undo',
                                                        textColor:
                                                            ColorTheme.text(
                                                                themeValue),
                                                        onPressed: () {
                                                          setState(() {
                                                            poemListBox
                                                                .add(poemData);
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
                                              Material(
                                                child: ListTile(
                                                  trailing: IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        barrierDismissible:
                                                            true,
                                                        context: context,
                                                        builder: (context) {
                                                          String editedTitle =
                                                              poemTitle;
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0), // Add border radius here
                                                            ),
                                                            child: AlertDialog(
                                                              backgroundColor:
                                                                  ColorTheme.accent(
                                                                      themeValue),
                                                              title:
                                                                  !isWideScreen
                                                                      ? Text(
                                                                          "Edit the poem title:",
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              color: ColorTheme.text(themeValue),
                                                                              fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                        )
                                                                      : Text(
                                                                          "Edit the poem title:",
                                                                          style: TextStyle(
                                                                              fontSize: 26,
                                                                              color: ColorTheme.text(themeValue),
                                                                              fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                        ),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  TextField(
                                                                    onChanged:
                                                                        (value) {
                                                                      editedTitle =
                                                                          value;
                                                                    },
                                                                    cursorColor:
                                                                        ColorTheme.text(
                                                                            themeValue),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        borderSide:
                                                                            BorderSide(color: ColorTheme.text(themeValue)), // Set the focused border color to black
                                                                      ),
                                                                      focusColor:
                                                                          ColorTheme.accent(
                                                                              themeValue),
                                                                      hintText:
                                                                          "Poem Name",
                                                                      hintStyle: !isWideScreen
                                                                          ? TextStyle(
                                                                              fontSize:
                                                                                  20,
                                                                              color: Colors
                                                                                  .black,
                                                                              fontFamily: GoogleFonts.ebGaramond()
                                                                                  .fontFamily)
                                                                          : TextStyle(
                                                                              fontSize: 26,
                                                                              color: Colors.black,
                                                                              fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        borderSide:
                                                                            const BorderSide(color: Colors.grey),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .grey[200],
                                                                      contentPadding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        vertical:
                                                                            12.0,
                                                                        horizontal:
                                                                            16.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  style: ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStatePropertyAll(
                                                                              ColorTheme.primary(themeValue))),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      !isWideScreen
                                                                          ? Text(
                                                                              "Cancel",
                                                                              style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                            )
                                                                          : Text(
                                                                              "Cancel",
                                                                              style: TextStyle(fontSize: 26, color: Colors.black, fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                            ),
                                                                ),
                                                                TextButton(
                                                                  style: ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStatePropertyAll(
                                                                              ColorTheme.primary(themeValue))),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      var poemData = poemListBox
                                                                          .getAt(
                                                                              index) as Map<
                                                                          dynamic,
                                                                          dynamic>;
                                                                      poemData[
                                                                              'title'] =
                                                                          editedTitle;
                                                                      poemListBox.putAt(
                                                                          index,
                                                                          poemData);
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      !isWideScreen
                                                                          ? Text(
                                                                              "Save",
                                                                              style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                            )
                                                                          : Text(
                                                                              "Save",
                                                                              style: TextStyle(fontSize: 26, color: Colors.black, fontFamily: GoogleFonts.ebGaramond().fontFamily),
                                                                            ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit),
                                                  ),
                                                  title: Text(
                                                    poemTitle,
                                                    style: !isWideScreen
                                                        ? TextStyle(
                                                            fontSize: 19,
                                                            color: Colors.black,
                                                            fontFamily: GoogleFonts
                                                                    .ebGaramond()
                                                                .fontFamily)
                                                        : TextStyle(
                                                            fontSize: 26,
                                                            color: Colors.black,
                                                            fontFamily: GoogleFonts
                                                                    .ebGaramond()
                                                                .fontFamily),
                                                  ),
                                                  tileColor:
                                                      ColorTheme.secondary(
                                                          themeValue),
                                                  onTap: () {
                                                    // print(poemIndex);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PoetryEditor(
                                                                      editorAppbarColor:
                                                                          ColorTheme.accent(
                                                                              themeValue),
                                                                      editorFontColor:
                                                                          ColorTheme.text(
                                                                              themeValue),
                                                                      editorPrimaryColor:
                                                                          ColorTheme.primary(
                                                                              themeValue),
                                                                      poemIndex:
                                                                          index,
                                                                    )));
                                                  },
                                                  splashColor:
                                                      ColorTheme.accent(
                                                          themeValue),
                                                ),
                                              ),
                                              if (index !=
                                                  poemListBox.length - 1)
                                                const Divider(
                                                  height: 1,
                                                  color: Colors.grey,
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 300,
                                        child: RiveAnimation.asset(
                                            ColorTheme.riveEmptyListAnimation(
                                                themeValue)),
                                      ),
                                      Text(
                                        "You haven't written any poetry yet ...",
                                        style: !isWideScreen
                                            ? TextStyle(
                                                fontSize: 20,
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
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "Add Poem",
          style: TextStyle(
              fontSize: !isWideScreen ? 16 : 26,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.ebGaramond().fontFamily),
        ),
        backgroundColor: ColorTheme.accent(themeValue),
        onPressed: () {
          if (isTemplateClicked) {
            int newPoemIndex = currentPoemIndex + 1;
            poemListIndexBox.put('poemIndex', newPoemIndex);
            var setPoemTitle =
                "Untitled-${poemListIndexBox.get('poemIndex')}  $setPoemType";
            setPoemList(
                setPoemTitle, setPoemType, features, "", setPoemMeter, []);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PoetryEditor(
                          editorAppbarColor: ColorTheme.accent(themeValue),
                          editorFontColor: ColorTheme.text(themeValue),
                          editorPrimaryColor: ColorTheme.primary(themeValue),
                          poemIndex: newPoemIndex,
                        )));
          } else if (isCustomTemplate) {
            if (selectedCustomTemplateIndex == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuickMode(
                            features: customPoetryTemplateSelection,
                          )));
            } else {
              int newPoemIndex = currentPoemIndex + 1;
              poemListIndexBox.put('poemIndex', newPoemIndex);
              String poemType = customPoetryTemplateSelection[0];
              String poemMeter =
                  "${customPoetryTemplateSelection[0]} with ${customPoetryTemplateSelection[1]} syllables";
              var poemTitle =
                  "Custom Untitled-${poemListIndexBox.get('poemIndex')}  $poemType";
              setPoemList(poemTitle, poemType, customPoetryTemplateSelection,
                  "", poemMeter, []);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PoetryEditor(
                            editorAppbarColor: ColorTheme.accent(themeValue),
                            editorFontColor: ColorTheme.text(themeValue),
                            editorPrimaryColor: ColorTheme.primary(themeValue),
                            poemIndex: newPoemIndex,
                          )));
            }
          } else {
            final snackBar = SnackBar(
              content: Text(
                'Select a template first!',
                style: !isWideScreen
                    ? TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: GoogleFonts.ebGaramond().fontFamily)
                    : TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontFamily: GoogleFonts.ebGaramond().fontFamily),
              ),
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
    );
  }
}
