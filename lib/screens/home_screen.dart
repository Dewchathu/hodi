import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/media.dart';
import '../wedgits/floating_rectangle.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashVisible = true;
  bool isFlashOn = false;
  final List<Media> _selectedMedias = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                FloatingRectangle(
                  onCameraVisibilityChanged: (isVisible) {
                    setState(() {
                      _isFlashVisible = isVisible;
                    });
                  },selectedMedias: _selectedMedias, isFlashOn: isFlashOn,
                ),
                SafeArea(
                    child: Container(
                      height: 50,
                      color: Colors.black.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.close, color: Colors.white),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    isFlashOn = !isFlashOn;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: _isFlashVisible
                                        ?isFlashOn
                                        ?const Icon(Icons.flash_on, color: Colors.white)
                                        :const Icon(Icons.flash_off, color: Colors.white)
                                        : Container(),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Spacer(),
                          const Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white),
                          const SizedBox(width: 16),
                        ],
                      ),
                    )
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

