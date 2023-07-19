import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      body: Center(
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
          ],
        ),
      ),
    );
  }
}
