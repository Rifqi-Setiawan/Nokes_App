import 'package:flutter/material.dart';

// Widget displaying SPBU information in a gradient blue card design
// Shows greeting message, SPBU location, and camera connection status
class SpbuInfoCard extends StatelessWidget {
  const SpbuInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 35),
          _buildWelcomeSection(),
          const SizedBox(height: 16),
          _buildInfoContainer(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Creates container decoration with gradient background and shadow
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Builds welcome section with title and subtitle messaging
  Widget _buildWelcomeSection() {
    return const Column(
      children: [
        Text(
          'Selamat Datang di Nokes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'SPBU Aman Tanpa Asap',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // Creates semi-transparent container for location and camera status information
  Widget _buildInfoContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildLocationInfo(),
          const SizedBox(height: 15),
          _buildCameraStatus(),
        ],
      ),
    );
  }

  // Displays SPBU location information with location icon
  Widget _buildLocationInfo() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on,
          color: Colors.white,
          size: 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lokasi SPBU:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                'SPBU 34.123.45 - Jakarta Timur',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Shows camera connection status with visual indicator
  Widget _buildCameraStatus() {
    return const Row(
      children: [
        _StatusIndicator(isConnected: true),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Kamera:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            Text(
              'Terhubung',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Private widget for displaying circular connection status indicator
class _StatusIndicator extends StatelessWidget {
  final bool isConnected;

  const _StatusIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isConnected ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
