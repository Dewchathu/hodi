import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:loading_indicator/loading_indicator.dart';

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
                          const SizedBox(width: 20),
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
                                        ? const Icon(Icons.flash_on,
                                            color: Colors.white)
                                        : const Icon(Icons.flash_off,
                                            color: Colors.white)
                                    : Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      PopupMenuButton<int>(
                        icon: const Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white),
                        onSelected: (value) {
                          switch (value) {
                            case 0:
                              _showTermsAndConditions(context);
                              break;
                            case 1:
                              _showPrivacy(context);
                              break;
                            case 2:
                              _showFeedback(context);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<int>(
                            value: 0,
                            child: Text('Terms and Conditions'),
                          ),
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text('Privacy'),
                          ),
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text('Feedback'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                )),
              ],
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 100,
                            height: 100,
                          ),
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "powered by",
                            style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontSize: 10,
                            ),
                          ),
                          TextSpan(
                            text: " SeventhColour",
                            style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void showConnectivitySnackBar(BuildContext context, bool isConnected) {
    final IconData iconData = isConnected ? Icons.wifi : Icons.wifi_off;
    final color = isConnected ? Colors.green : const Color(0xFFC6293C);
    final text =
        isConnected ? 'Connected to internet!' : 'No internet connection.';

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
        top: MediaQuery.of(context).padding.top +
            kToolbarHeight +
            8, // Adjust as needed
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
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms and Conditions'),
        content: Text('Terms and Conditions content goes here...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy'),
        content: Text('Privacy content goes here...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Feedback'),
        content: Text('Feedback content goes here...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
