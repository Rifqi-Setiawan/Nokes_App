import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/widgets.dart';

// Main view component for home page displaying SPBU information and camera monitoring
// Implements clean architecture with widget separation into dedicated files
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

  // Constructs scrollable main content area with proper spacing
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Column(
        children: [
          CameraMonitoringCard(),
          SizedBox(height: 20),
          SmokingDetectionCard(),
          SizedBox(height: 20),
          // Reserved space for future widget additions
        ],
      ),
    );
  }
}
