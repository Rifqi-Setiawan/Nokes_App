import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraPreviewArea extends StatelessWidget {
  const CameraPreviewArea({super.key});

  @override
  Widget build(BuildContext context) {
    // Static stream URL configuration - should be replaced with dynamic controller value
    final streamUrl = 'http://192.168.5.186:5000/video';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: Mjpeg(
          stream: streamUrl,
          isLive: true,
          fit: BoxFit.cover,
          error: (context, error, stack) {
            print('🛑 MJPEG Stream Error: $error');
            return const Center(child: Text("Gagal menampilkan kamera"));
          },
          loading: (context) {
            print('⌛ MJPEG Stream Loading...');
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
