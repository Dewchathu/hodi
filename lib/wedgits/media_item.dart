import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hodi/screens/text_output_screen.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import '../models/media.dart';
import '../models/media_processing_results.dart';

class MediaItem extends StatefulWidget {
  final Media media;
  const MediaItem({Key? key, required this.media}) : super(key: key);

  @override
  _MediaItemState createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _handleMediaSelection(context, widget.media);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: double.infinity,
                child: widget.media.widget
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 30,
              height: 30,
              child: LoadingIndicator(
                indicatorType: Indicator.circleStrokeSpin,
                colors: [Colors.red],
                strokeWidth: 3,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  void _handleMediaSelection(BuildContext context, Media media) {
    setState(() {
      _isLoading = true;
    });

    _sendMedia(media).then((result) {
      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextOutputScreen(media: media, isCameraImage: false, result: result.result),
        ),
      );
    });
  }

  Future<MediaProcessingResult> _sendMedia(Media media) async {
    try {
      final file = await media.assetEntity.file;

      if (file != null) {
        final fileBytes = await file.readAsBytes();
        final mediaBase64 = base64Encode(fileBytes);

        final response = await http.post(
          Uri.parse('https://2dc2-175-157-57-90.ngrok-free.app/process_image'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'image': mediaBase64, 'filename': media.assetEntity.title}),
        );

        if (response.statusCode == 200) {
          print('Media processing complete');
          final result = jsonDecode(response.body)['result'];
          return MediaProcessingResult(result);
        } else {
          print('Media processing failed with status code: ${response.statusCode}');
          return MediaProcessingResult('Error');
        }
      } else {
        print('Error: File not found for media ${media.assetEntity.title}');
        return MediaProcessingResult('File not found');
      }
    } catch (e) {
      print('Error sending media: $e');
      return MediaProcessingResult('Error: $e');
    }
  }
}