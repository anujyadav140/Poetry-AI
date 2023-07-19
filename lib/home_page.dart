import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/components/rive_display.dart';
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
  @override
  void initState() {
    // selectedColor = globalThemeBox.get('theme', defaultValue: 'Green');
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
                child: Row(
                  children: [
                    Template(
                      templateBoxColor:
                          ColorTheme.primary(globalThemeBox.get('theme')),
                      templateSplashColor:
                          ColorTheme.secondary(globalThemeBox.get('theme')),
                    ),
                    Template(
                      templateBoxColor:
                          ColorTheme.primary(globalThemeBox.get('theme')),
                      templateSplashColor:
                          ColorTheme.secondary(globalThemeBox.get('theme')),
                    ),
                    Template(
                      templateBoxColor:
                          ColorTheme.primary(globalThemeBox.get('theme')),
                      templateSplashColor:
                          ColorTheme.secondary(globalThemeBox.get('theme')),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                  child: Container(
                    color: ColorTheme.secondary(globalThemeBox.get('theme')),
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          child: const RiveAnimation.asset(
                              "assets/empty-living-room.riv"),
                        ),
                        const Text("You haven't written any poetry yet ..."),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the action when the button is pressed
          // Add your logic here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
