import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/components/template_card.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('myBox');
  final globalThemeBox = Hive.box('myThemeBox');
  PoetryType poetryTypeName = PoetryType("", "", [""]);
  bool isTemplateClicked = false;
  List<String> features = [""];
  int selectedTemplateIndex = -1;
  @override
  void initState() {
    globalThemeBox.get('theme');
    super.initState();
  }

  void writeData() {
    _myBox.put(1, "anuj");
  }

  void readData() {
    _myBox.get(1);
    print(_myBox.get(1));
  }

  void deleteData() {
    _myBox.delete(1);
    print("data deleted!");
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
    "Green",
    "Purple",
  ];

  // String selectedColor = "Green";
  // Default color
  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a theme ...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: themeList.map((theme) {
                return ListTile(
                  title: Text(theme),
                  onTap: () {
                    if (theme == "Purple") {
                      setState(() {
                        setGlobalTheme(theme);
                        // ColorTheme.selectedColor = "Purple";
                      });
                      print("Purple Theme Selected");
                    } else if (theme == "Green") {
                      setState(() {
                        setGlobalTheme(theme);
                        // ColorTheme.selectedColor = "Green";
                      });
                      print("Green Theme Selected");
                    }
                    Navigator.pop(context); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void logout() async {
      //show loading
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      AuthService().logout();
      //pop the loading
      Navigator.pop(context);
    }

    void onTapTemplate(int index) {
      setState(() {
        if (selectedTemplateIndex == index) {
          // If the same template is tapped again, unselect it and set isTemplateClicked to false
          selectedTemplateIndex = -1;
          isTemplateClicked = false;
        } else {
          // Otherwise, select the template and set isTemplateClicked to true
          selectedTemplateIndex = index;
          isTemplateClicked = true;
          poetryTypeName = PoetryTypesData.getPoetryTypeByName(
              PoetryTypesData.poetryTypes[index].name);
          features = PoetryTypesData.getFeaturesByName(poetryTypeName.name);
          print(features);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome back!",
          style: TextStyle(color: ColorTheme.text(globalThemeBox.get('theme'))),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'themes') {
                showThemeDialog(context); // Show the theme dialog
              } else if (value == 'logout') {
                logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'themes',
                child: ListTile(
                  leading: Icon(Icons.palette),
                  title: Text("Themes"),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ),
            ],
          )
        ],
      ),
      backgroundColor: ColorTheme.accent(globalThemeBox.get('theme')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (int i = 0; i < PoetryTypesData.poetryTypes.length; i++)
                    Template(
                      templateBoxColor:
                          ColorTheme.primary(globalThemeBox.get('theme')),
                      templateSplashColor:
                          ColorTheme.secondary(globalThemeBox.get('theme')),
                      name: PoetryTypesData.poetryTypes[i].name,
                      description: PoetryTypesData.poetryTypes[i].description,
                      onTap: () => onTapTemplate(i),
                      isSelected: selectedTemplateIndex == i,
                    ),
                ]),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                  child: ClipPath(
                    child: Container(
                      color: ColorTheme.secondary(globalThemeBox.get('theme')),
                      child: isTemplateClicked
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
                                    child: Text(
                                      "Features for ${poetryTypeName.name}:",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: features.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: const Icon(
                                              Icons.fiber_manual_record),
                                          title: Text(features[index]),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                  child: const RiveAnimation.asset(
                                      "assets/empty-living-room.riv"),
                                ),
                                const Text(
                                    "You haven't written any poetry yet ..."),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              // ClipPath(
              //   clipper: MyClipper(),
              //   child: Container(
              //     width: double.infinity,
              //     height: 50,
              //     color: Colors.black,
              //   ),
              // )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTheme.accent(globalThemeBox.get('theme')),
        onPressed: () {
          // Handle the action when the button is pressed
          // Add your logic here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
          size.width / 4, size.height - 40, size.width / 2, size.height - 20)
      ..quadraticBezierTo(
          3 / 4 * size.width, size.height, size.width, size.height - 30)
      ..lineTo(size.width, 0);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
