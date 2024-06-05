import 'package:flutter/material.dart';
import 'package:hodi/wedgits/media_item.dart';
import '../models/media.dart';

class MediaGridView extends StatelessWidget {
  final List<Media> medias;
  const MediaGridView({Key? key, required this.medias}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: medias.length,
      itemBuilder: (BuildContext context, int index) {
        return MediaItem(media: medias[index]); // Call a function to build the tile
      },
    );
  }
}
