import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Widget untuk menampilkan tombol kontrol kamera (Refresh dan Settings)
class CameraControlButtons extends GetView<HomeController> {
  const CameraControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildRefreshButton(),
          const SizedBox(width: 12),
          _buildSettingsButton(),
        ],
      ),
    );
  }

  /// Tombol refresh stream kamera
  Widget _buildRefreshButton() {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _handleRefreshPressed,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Refresh'),
        style: _buildPrimaryButtonStyle(),
      ),
    );
  }

  /// Tombol pengaturan kamera
  Widget _buildSettingsButton() {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: _handleSettingsPressed,
        icon: const Icon(Icons.settings, size: 18),
        label: const Text('Ganti'),
        style: _buildSecondaryButtonStyle(),
      ),
    );
  }

  ButtonStyle _buildPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonStyle _buildSecondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.grey[700],
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide(color: Colors.grey[300]!),
    );
  }

  /// Aksi saat tombol refresh ditekan
  void _handleRefreshPressed() {
    controller.refreshCamera(); // Pastikan ini mengganti streamUrl
    _showFeedbackSnackbar(
      'Refresh Kamera',
      'Kamera sedang di-refresh...',
      Colors.blue,
    );
  }

  /// Aksi saat tombol setting ditekan
  void _handleSettingsPressed() {
    Get.bottomSheet(
      _buildCameraSettingsBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  /// Bottom sheet pengaturan kamera
  Widget _buildCameraSettingsBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottomSheetHeader(),
          const SizedBox(height: 20),
          _buildSettingsOptions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHeader() {
    return Row(
      children: [
        const Icon(Icons.settings, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          'Pengaturan Kamera',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return Column(
      children: [
        _buildSettingTile(
          icon: Icons.switch_camera,
          title: 'Pilih Kamera Laptop',
          subtitle: 'Jika tersedia lebih dari satu webcam',
          onTap: _handleSwitchCamera,
        ),
        _buildSettingTile(
          icon: Icons.high_quality,
          title: 'Kualitas Video',
          subtitle: 'Ubah resolusi stream MJPEG',
          onTap: _handleVideoQuality,
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _handleSwitchCamera() {
    Get.back();
    // TODO: Buat ganti URL stream ke /video?camera=1 jika backend support
    _showFeedbackSnackbar(
      'Ganti Kamera',
      'Fitur ganti kamera akan segera tersedia',
      Colors.orange,
    );
  }

  void _handleVideoQuality() {
    Get.back();
    // TODO: Implement jika backend mendukung multiple resolution
    _showFeedbackSnackbar(
      'Kualitas Video',
      'Pengaturan kualitas video akan segera tersedia',
      Colors.orange,
    );
  }

  void _showFeedbackSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.1),
      colorText: color,
      duration: const Duration(seconds: 2),
    );
  }
}
