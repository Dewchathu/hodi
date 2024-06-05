import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media.dart';
import '../wedgits/media_item.dart';
import 'package:http/http.dart' as http;

class TextOutputScreen extends StatefulWidget {
  final Media? media;
  final File? file;
  final bool isCameraImage;
  final String result;
  const TextOutputScreen(
      {Key? key,
        this.media,
        required this.isCameraImage,
        this.file,
        required this.result})
      : super(key: key);

  @override
  State<TextOutputScreen> createState() => _TextOutputScreenState();
}

class _TextOutputScreenState extends State<TextOutputScreen> {
  TextEditingController controller = TextEditingController();

  _copy() async {
    final value = ClipboardData(text: controller.text);
    Clipboard.setData(value);
  }

  @override
  void initState() {
    super.initState();
    controller.text = widget.result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(
            children: [
              !widget.isCameraImage
                  ? SizedBox(width: 100, child: MediaItem(media: widget.media!))
                  : SizedBox(width: 100, child: Image.file(widget.file!)),
              const SizedBox(height: 20),
              TextField(
                  minLines: 1,
                  maxLines: 10,
                  controller: controller,
                  decoration: const InputDecoration(
                      fillColor: Colors.grey, border: OutlineInputBorder())),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _copy,
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              )
            ],
          ),
        ));
  }
}