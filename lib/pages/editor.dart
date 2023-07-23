import 'package:flutter/material.dart';

class PoetryEditor extends StatefulWidget {
  const PoetryEditor({super.key});

  @override
  State<PoetryEditor> createState() => _PoetryEditorState();
}

class _PoetryEditorState extends State<PoetryEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editor"), actions: [
        IconButton(
            onPressed: () => Navigator.pop(context), icon: const Icon(Icons.back_hand))
      ]),
      body: const SafeArea(child: Text("Editor page!")),
    );
  }
}
