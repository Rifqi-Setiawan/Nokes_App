import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Widget untuk menampilkan status deteksi merokok real-time dari YOLOv8
class SmokingDetectionCard extends GetView<HomeController> {
  const SmokingDetectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildDetectionStatus(),
          _buildStatistics(),
        ],
      ),
    );
  }

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.smoking_rooms_outlined, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Deteksi Aktivitas Merokok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Obx(() => _buildStatusBadge()),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isDetected = controller.smokingDetected.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDetected ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDetected ? Colors.red[300]! : Colors.green[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDetected ? Colors.red : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isDetected ? 'DETECTED' : 'CLEAR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDetected ? Colors.red[700] : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionStatus() {
    return Obx(() {
      final isDetected = controller.smokingDetected.value;
      final confidence = controller.detectionConfidence.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDetected ? Colors.red[50] : Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDetected ? Colors.red[200]! : Colors.green[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDetected ? Icons.warning : Icons.check_circle,
                  color: isDetected ? Colors.red[600] : Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDetected
                            ? '⚠️ Aktivitas Merokok Terdeteksi!'
                            : '✅ Area Aman dari Asap Rokok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDetected ? Colors.red[700] : Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDetected
                            ? 'Deteksi dengan tingkat kepercayaan ${(confidence * 100).toInt()}%'
                            : 'Monitoring aktif - tidak ada aktivitas merokok',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDetected ? Colors.red[600] : Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isDetected && confidence > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Tingkat Kepercayaan: ${(confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: confidence,
                backgroundColor: Colors.red[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                minHeight: 6,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatistics() {
    return Obx(() => Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Deteksi',
              controller.totalDetections.value.toString(),
              Icons.analytics,
              Colors.blue,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: _buildStatItem(
              'Deteksi Terakhir',
              _formatLastDetection(),
              Icons.access_time,
              Colors.orange,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatLastDetection() {
    final value = controller.lastDetectionTime.value;
    return value.isEmpty ? 'Belum ada' : value;
  }
}
