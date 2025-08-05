import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Widget utama untuk menampilkan monitoring kamera via MJPEG stream dari laptop.
/// Menampilkan live video stream dengan error handling dan loading states.
class CameraMonitoringCard extends GetView<HomeController> {
  const CameraMonitoringCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildVideoStreamContainer(),
          _buildControlButtons(),
          _buildDetectionStatus(),
        ],
      ),
    );
  }

  /// Membangun dekorasi card utama
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Membangun header dengan judul dan status indikator
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Pantauan Kamera Langsung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          _buildStreamStatusIndicator(),
        ],
      ),
    );
  }

  /// Membangun indikator status stream
  Widget _buildStreamStatusIndicator() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: controller.isStreamActive.value 
          ? Colors.green.withOpacity(0.1) 
          : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: controller.isStreamActive.value ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            controller.isStreamActive.value ? 'LIVE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: controller.isStreamActive.value ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    ));
  }

  /// Membangun container untuk video stream
  Widget _buildVideoStreamContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Obx(() => _buildVideoContent()),
      ),
    );
  }

  /// Membangun konten video berdasarkan status
  Widget _buildVideoContent() {
    if (controller.streamError.value.isNotEmpty) {
      return _buildErrorState();
    } else if (controller.isStreamLoading.value) {
      return _buildLoadingState();
    } else {
      return _buildVideoStream();
    }
  }

  /// Membangun tampilan error
  Widget _buildErrorState() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Koneksi Terputus',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              controller.streamError.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.reconnectStream(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tampilan loading
  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey[100],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Menghubungkan ke kamera...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun video stream MJPEG
  Widget _buildVideoStream() {
    return Stack(
      children: [
        Mjpeg(
          stream: controller.streamUrl.value,
          isLive: true,
          error: _buildStreamError,
          loading: _buildStreamLoading,
          timeout: const Duration(seconds: 5),
          // Tambahan konfigurasi untuk mengurangi buffering
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        _buildVideoOverlay(),
      ],
    );
  }

  /// Membangun error widget untuk MJPEG
  Widget _buildStreamError(BuildContext context, dynamic error, dynamic stackTrace) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.handleStreamError(error.toString());
    });
    
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(
          Icons.videocam_off,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Membangun loading widget untuk MJPEG
  Widget _buildStreamLoading(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setStreamLoading(true);
    });
    
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// Membangun overlay di atas video
  Widget _buildVideoOverlay() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Obx(() => Text(
          controller.getStreamQuality(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }

  /// Membangun tombol kontrol
  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.toggleStream(),
              icon: Obx(() => Icon(
                controller.isStreamActive.value ? Icons.stop : Icons.play_arrow,
                size: 18,
              )),
              label: Obx(() => Text(
                controller.isStreamActive.value ? 'Stop' : 'Start',
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.showStreamSettings(),
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun status deteksi
  Widget _buildDetectionStatus() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tidak Terdeteksi Merokok',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Area aman dari aktivitas merokok',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
