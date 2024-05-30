import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hodi/services/fetch_albums.dart';
import 'package:hodi/services/fetch_media.dart';
import 'package:hodi/wedgits/media_grid_view.dart';
import 'package:hodi/wedgits/media_item.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:http/http.dart' as http;

import '../models/media.dart';

class FloatingRectangle extends StatefulWidget {
  final Function(bool) onCameraVisibilityChanged;
  final List<Media> selectedMedias;
  final bool isFlashOn;

  const FloatingRectangle(
      {Key? key, required this.onCameraVisibilityChanged, required this.selectedMedias, required this.isFlashOn})
      : super(key: key);

  @override
  _FloatingRectangleState createState() => _FloatingRectangleState();
}

class _FloatingRectangleState extends State<FloatingRectangle> {
  late double _bottomPosition;
  late double _height;
  late CameraController cameraController;
  late Future<void> vameraValue;
  bool _isCameraVisible = true;
  final List<Media> _selectedMedias = [];

  AssetPathEntity? _currentAlbum;
  List<AssetPathEntity> _albums = [];

  void _loadAlbums() async {
    List<AssetPathEntity> albums = await fetchAlbums();
    if (albums.isNotEmpty) {
      setState(() {
        _currentAlbum = albums.first;
        _albums = albums;
      });
      _loadMedias();
    }
  }

  final List<Media> _medias = [];
  int _lastPage = 0;
  int _currentsPage = 0;

  void _loadMedias() async {
    _lastPage = _currentsPage;
    if (_currentAlbum != null) {
      List<Media> medias =
          await fetchMedias(albums: _currentAlbum!, page: _currentsPage);
      setState(() {
        _medias.addAll(medias);
      });
    }
  }
  Future<void> _sendImage(String imagePath) async {
    try {
      final imageBytes = File(imagePath).readAsBytesSync();
      final imageBase64 = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('http://your_server_ip:5000/process_image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': imageBase64}),
      );

      if (response.statusCode == 200) {
        print('Image processing complete');
        print(jsonDecode(response.body)['result']);
      } else {
        print('Image processing failed');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  void takePicture() async{
    XFile? image;

    if(cameraController.value.isTakingPicture || !cameraController.value.isInitialized){
      return;
    }
    if(widget.isFlashOn == false){
      await cameraController.setFlashMode(FlashMode.off);
    }else{
      await cameraController.setFlashMode(FlashMode.torch);
    }
    image = await cameraController.takePicture();
    if(cameraController.value.flashMode == FlashMode.torch){
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }
    final file = await _sendImage(image.path);
  }

  @override
  void initState() {
    super.initState();
    _bottomPosition = 0.0;
    _height = 150.0;
    _selectedMedias.addAll(widget.selectedMedias);
    _loadAlbums();
  }

//final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 4 / 6;
    return Positioned(
      bottom: _bottomPosition,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            double newHeight = _height - details.primaryDelta!;
            _height = newHeight.clamp(150.0, screenHeight);
            _updateIconVisibility();
          });
        },
        onVerticalDragEnd: (details) {
          if (_height > screenHeight / 2) {
            _animateToHeight(screenHeight);
          } else {
            _animateToHeight(150.0);
          }
          _updateIconVisibility();
        },
        child: Column(
          children: [
            if (!_isCameraVisible)
              GestureDetector(
                onTap: () {
                  _animateToHeight(150.0);
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 50,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _height,
              decoration:BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: _isCameraVisible
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _medias.isNotEmpty
                              ? MediaItem(media: _medias.first)
                              : Container(),
                        ),
                        GestureDetector(
                          onTap: () {
                            takePicture;
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.circular(80),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          color: Theme.of(context).canvasColor,
                        ),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: DropdownButton<AssetPathEntity>(
                                    value: _currentAlbum,
                                    onChanged: (value) {
                                      setState(() {
                                        _currentAlbum = value;
                                        _currentsPage = 0;
                                        _medias.clear();
                                      });
                                      _loadMedias();
                                    },
                                    items: _albums
                                        .map((e) => DropdownMenuItem<AssetPathEntity>(
                                      value: e,
                                      child: Text(e.name.isEmpty ? "0" : e.name),
                                    ))
                                        .toList(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    alignment: Alignment.centerLeft,
                                    underline: Container(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Handle 'View all' tap
                                },
                                child: const Text(
                                  'View all',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: MediaGridView(medias: _medias)
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _animateToHeight(double targetHeight) {
    setState(() {
      _height = targetHeight;
    });
    _updateIconVisibility();
  }

  void _updateIconVisibility() {
    setState(() {
      _isCameraVisible = _height < MediaQuery.of(context).size.height * 1 / 4;
    });
    widget.onCameraVisibilityChanged(_isCameraVisible);
  }
}
