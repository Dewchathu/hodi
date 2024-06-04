import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
  bool isConnectedToInternet = false;
  final List<Media> _selectedMedias = [];

  StreamSubscription? _internetConnectionStreamSubscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen((event) {
          switch (event) {
            case InternetStatus.connected:
              setState(() {
                isConnectedToInternet = true;
              });
              showConnectivitySnackBar(context, isConnectedToInternet);
              break;
            case InternetStatus.disconnected:
              setState(() {
                isConnectedToInternet = false;
              });
              showConnectivitySnackBar(context, isConnectedToInternet);
              break;
            default:
              setState(() {
                isConnectedToInternet = false;
              });
              showConnectivitySnackBar(context, isConnectedToInternet);
          }
        });
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _internetConnectionStreamSubscription?.cancel();
    removeCustomSnackBar();
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
                  },
                  selectedMedias: _selectedMedias,
                  isFlashOn: isFlashOn,
                  cameraController: _controller,
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
                              GestureDetector(
                                onTap: () {
                                  if (Platform.isAndroid) {
                                    SystemNavigator.pop();
                                  } else if (Platform.isIOS) {
                                    exit(0);
                                  }
                                },
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFlashOn = !isFlashOn;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: _isFlashVisible
                                        ? isFlashOn
                                        ? const Icon(
                                        Icons.flash_on, color: Colors.white)
                                        : const Icon(Icons.flash_off,
                                        color: Colors.white)
                                        : Container(),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Spacer(),
                          const Icon(CupertinoIcons.ellipsis_vertical,
                              color: Colors.white),
                          const SizedBox(width: 16),
                        ],
                      ),
                    )),
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

  void showConnectivitySnackBar(BuildContext context, bool isConnected) {
    final IconData iconData = isConnected ? Icons.wifi : Icons.wifi_off;
    final color = isConnected ? Colors.green : Colors.red;
    final text = isConnected ? 'Connected to internet!' : 'No internet connection.';

    removeCustomSnackBar(); // Remove any existing snackbar before showing a new one
    _overlayEntry = _createOverlayEntry(iconData, text, color);
    Overlay.of(context)?.insert(_overlayEntry!);

    if (isConnected) {
      Future.delayed(const Duration(seconds: 3), () {
        removeCustomSnackBar();
      });
    }
  }

  void removeCustomSnackBar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(IconData icon, String text, Color color) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 8, // Adjust as needed
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
