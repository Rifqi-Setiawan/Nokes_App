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

  /// Membangun tombol refresh
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

  /// Membangun tombol settings/ganti
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

  /// Style untuk tombol primary (refresh)
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

  /// Style untuk tombol secondary (settings)
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

  /// Handler untuk tombol refresh
  void _handleRefreshPressed() {
    controller.refreshCamera();
    _showFeedbackSnackbar(
      'Refresh Camera',
      'Kamera sedang di-refresh...',
      Colors.blue,
    );
  }

  /// Handler untuk tombol settings
  void _handleSettingsPressed() {
    _showCameraSettingsBottomSheet();
  }

  /// Menampilkan bottom sheet untuk pengaturan kamera
  void _showCameraSettingsBottomSheet() {
    Get.bottomSheet(
      _buildCameraSettingsBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  /// Membangun bottom sheet untuk pengaturan kamera
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

  /// Membangun header bottom sheet
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

  /// Membangun opsi pengaturan
  Widget _buildSettingsOptions() {
    return Column(
      children: [
        _buildSettingTile(
          icon: Icons.flip_camera_ios,
          title: 'Ganti Kamera',
          subtitle: 'Ubah ke kamera depan/belakang',
          onTap: _handleSwitchCamera,
        ),
        _buildSettingTile(
          icon: Icons.high_quality,
          title: 'Kualitas Video',
          subtitle: 'Ubah resolusi kamera',
          onTap: _handleVideoQuality,
        ),
        _buildSettingTile(
          icon: Icons.info_outline,
          title: 'Info Kamera',
          subtitle: 'Lihat informasi kamera',
          onTap: _handleCameraInfo,
        ),
      ],
    );
  }

  /// Membangun tile untuk setting individual
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

  /// Handler untuk switch kamera
  void _handleSwitchCamera() {
    Get.back();
    // TODO: Implement camera switching
    _showFeedbackSnackbar(
      'Switch Camera',
      'Fitur ganti kamera akan segera tersedia',
      Colors.orange,
    );
  }

  /// Handler untuk kualitas video
  void _handleVideoQuality() {
    Get.back();
    // TODO: Implement video quality settings
    _showFeedbackSnackbar(
      'Video Quality',
      'Pengaturan kualitas video akan segera tersedia',
      Colors.orange,
    );
  }

  /// Handler untuk info kamera
  void _handleCameraInfo() {
    Get.back();
    _showCameraInfoDialog();
  }

  /// Menampilkan dialog info kamera
  void _showCameraInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Informasi Kamera'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status', controller.isCameraInitialized.value ? 'Aktif' : 'Tidak Aktif'),
            _buildInfoRow('Resolusi', 'Medium (720p)'),
            _buildInfoRow('FPS', '30'),
            _buildInfoRow('Audio', 'Disabled'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Membangun baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  /// Menampilkan snackbar feedback
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
