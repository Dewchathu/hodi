import 'package:flutter/material.dart';
import 'package:hodi/screens/text_output_screen.dart';

import '../models/media.dart';

class MediaItem extends StatelessWidget {
  final Media media;
  const MediaItem({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _handleMediaSelection(context, media);
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: media.widget,
      ),
    );
  }
}

void _handleMediaSelection(BuildContext context, Media media) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TextOutputScreen(media: media),
    ),
  );
}
