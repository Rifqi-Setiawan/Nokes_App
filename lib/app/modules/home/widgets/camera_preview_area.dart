import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class CameraPreviewArea extends StatefulWidget {
  const CameraPreviewArea({super.key});

  @override
  State<CameraPreviewArea> createState() => _CameraPreviewAreaState();
}

class _CameraPreviewAreaState extends State<CameraPreviewArea> {
  late VlcPlayerController _vlcViewController;

  @override
  void initState() {
    super.initState();
    _vlcViewController = VlcPlayerController.network(
      'http://192.168.5.186:5000/video', // IP server kamu
      hwAcc: HwAcc.auto,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcViewController.stop();
    _vlcViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: VlcPlayer(
          controller: _vlcViewController,
          aspectRatio: 640 / 480,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
