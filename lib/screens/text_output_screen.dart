import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media.dart';
import '../wedgits/media_item.dart';

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
        body: SingleChildScrollView(
          child: Padding(
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
                  decoration: InputDecoration(
                    fillColor: Colors.grey,
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).focusColor),
                    ),
                  ),
                ),
          
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _copy,
                  icon: Icon(
                      Icons.copy,
                    color: Theme.of(context).focusColor,
                  ),
                  label: Text('Copy',
                  style: TextStyle(
                    color: Theme.of(context).focusColor
                  ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}