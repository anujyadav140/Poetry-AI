import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/colour_palette.dart';
import 'package:poetry_ai/components/rive_display.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:rive/rive.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _myBox = Hive.box('myBox');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Edit!"),
      // ),
      backgroundColor: ColorPalette.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              MaterialButton(
                onPressed: () {
                  writeData();
                  print("write");
                },
                child: Text("Write data"),
              ),
              MaterialButton(
                onPressed: () {
                  deleteData();
                  print("delete");
                },
                child: Text("Delete data"),
              ),
              MaterialButton(
                onPressed: () {
                  readData();
                  print("read");
                },
                child: Text("Read data"),
              ),
              MaterialButton(
                onPressed: () {
                  //show loading
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      });
                  AuthService().logout();
                  //pop the loading
                  Navigator.pop(context);
                },
                child: Text("LOGOUT"),
              ),
              // Text("You haven't written any poetry yet ..."),
              Flexible(
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                    child: Container(
                      color: ColorPalette.secondary,
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
                    )),
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
