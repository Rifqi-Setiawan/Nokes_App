import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/widgets.dart';

/// View utama untuk halaman home yang menampilkan informasi SPBU dan monitoring kamera.
/// Menggunakan clean architecture dengan pemisahan widget ke file terpisah.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SpbuInfoCard(),
        const SizedBox(height: 20),
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  /// Membangun konten utama dengan padding
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Column(
        children: [
          CameraMonitoringCard(),
          SizedBox(height: 20),
          SmokingDetectionCard(),
          SizedBox(height: 20),
          // Ruang untuk widget tambahan di masa depan
        ],
      ),
    );
  }
}
