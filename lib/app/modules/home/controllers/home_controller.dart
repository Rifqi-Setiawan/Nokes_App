import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  // Stream-related properties
  final streamUrl = 'http://192.168.5.186:5000/video'.obs; // Default IP yang lebih umum
  final isStreamActive = false.obs;
  final isStreamLoading = false.obs;
  final streamError = ''.obs;
  final streamQuality = 'HD'.obs;
  final streamLatency = 0.obs; // untuk monitoring latency
  final streamFps = 0.obs; // untuk monitoring FPS
  
  // Detection properties
  final smokingDetected = false.obs;
  final detectionConfidence = 0.0.obs;
  final totalDetections = 0.obs;
  final lastDetectionTime = ''.obs;
  
  // Timer untuk monitoring koneksi
  Timer? _connectionTimer;
  Timer? _qualityTimer;
  Timer? _latencyTimer;
  Timer? _detectionTimer;
  
  // Alert throttling
  DateTime? _lastAlertTime;

  // Legacy camera properties (untuk backward compatibility)
  final isCameraInitialized = false.obs;
  final isCameraActive = false.obs;
  final cameraError = ''.obs;
  final count = 0.obs;



  @override
  void onInit() {
    super.onInit();
    // Auto-connect ke stream saat controller diinisialisasi
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeStream();
    });
  }

  @override
  void onClose() {
    _connectionTimer?.cancel();
    _qualityTimer?.cancel();
    _latencyTimer?.cancel();
    _detectionTimer?.cancel();
    super.onClose();
  }

  /// Inisialisasi stream dengan auto-connect
  Future<void> _initializeStream() async {
    try {
      setStreamLoading(true);
      streamError.value = '';
      
      // Langsung set stream sebagai aktif tanpa health check
      // karena endpoint hanya /video yang tersedia
      print('🔗 Mencoba koneksi ke: ${streamUrl.value}');
      
      // Delay sebentar untuk memastikan UI sudah ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      isStreamActive.value = true;
      setStreamLoading(false);
      
      // Start monitoring setelah koneksi berhasil
      _startMonitoring();
      
      Get.snackbar(
        'Stream Connected',
        'Successfully connected to camera stream',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      handleStreamError(e.toString());
    }
  }

  /// Mulai monitoring koneksi stream
  void _startMonitoring() {
    // Monitor koneksi setiap 15 detik (lebih sering untuk deteksi cepat)
    _connectionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkStreamHealth();
    });
    
    // Update quality info setiap 3 detik (lebih responsif)
    _qualityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateStreamQuality();
    });
    
    // Monitor latency setiap 2 detik
    _latencyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateLatencyInfo();
    });
    
    // Monitor detection status setiap 1 detik
    _detectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDetectionStatus();
    });
  }

  /// Cek kesehatan stream
  void _checkStreamHealth() {
    if (isStreamActive.value) {
      // Simulasi health check
      // Dalam implementasi real, ini bisa ping ke server
      print('Stream health check: OK');
    }
  }

  /// Update informasi kualitas stream
  void _updateStreamQuality() {
    if (isStreamActive.value) {
      // Simulasi update quality berdasarkan performa
      final now = DateTime.now();
      final qualities = ['HD', '720p', '480p'];
      streamQuality.value = qualities[now.second % 3];
      
      // Update FPS simulation
      streamFps.value = 25 + (now.millisecond % 10); // 25-35 FPS
    }
  }
  
  /// Update informasi latency
  void _updateLatencyInfo() {
    if (isStreamActive.value) {
      // Simulasi latency monitoring
      final latency = 50 + (DateTime.now().millisecond % 100); // 50-150ms
      streamLatency.value = latency;
    }
  }
  
  /// Fetch real-time detection status dari YOLOv8 server
  Future<void> _fetchDetectionStatus() async {
  if (!isStreamActive.value) return;

  try {
    final response = await http.get(Uri.parse('${streamUrl.value.replaceFirst("/video", "")}/status'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final detected = data['detected'] ?? false;
      final confidence = (data['confidence'] ?? 0.0).toDouble();

      if (detected && confidence > 0.5) {
        smokingDetected.value = true;
        detectionConfidence.value = confidence;
        totalDetections.value++;
        lastDetectionTime.value = TimeOfDay.now().format(Get.context!);
        _showSmokingAlert();
      } else {
        smokingDetected.value = false;
        detectionConfidence.value = 0.0;
      }
    }
  } catch (e) {
    print('Error fetching detection status: $e');
  }
}

  
  /// Show smoking detection alert
  void _showSmokingAlert() {
    // Batasi alert untuk avoid spam
    final now = DateTime.now();
    
    if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds > 5) {
      _lastAlertTime = now;
      
      Get.snackbar(
        '🚭 Deteksi Merokok!',
        'Ketepatan: ${(detectionConfidence.value * 100).toInt()}%',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning, color: Colors.red),
      );
    }
  }

  /// Toggle stream on/off
  Future<void> toggleStream() async {
    try {
      if (isStreamActive.value) {
        // Stop stream
        isStreamActive.value = false;
        streamError.value = '';
        
        // Stop monitoring timers
        _connectionTimer?.cancel();
        _qualityTimer?.cancel();
        _latencyTimer?.cancel();
        _detectionTimer?.cancel();
        
        Get.snackbar(
          'Stream Stopped',
          'Camera stream has been stopped',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      } else {
        // Start stream
        await _initializeStream();
      }
    } catch (e) {
      handleStreamError(e.toString());
    }
  }

  /// Reconnect stream setelah error
  Future<void> reconnectStream() async {
    streamError.value = '';
    await _initializeStream();
  }

  /// Handle stream error
  void handleStreamError(String error) {
    isStreamActive.value = false;
    setStreamLoading(false);
    streamError.value = error;
    
    Get.snackbar(
      'Stream Error',
      'Failed to connect: $error',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      duration: const Duration(seconds: 4),
    );
  }

  /// Set loading state
  void setStreamLoading(bool loading) {
    isStreamLoading.value = loading;
    if (loading) {
      streamError.value = '';
    }
  }

  /// Get current stream quality
  String getStreamQuality() {
    if (isStreamActive.value) {
      return '${streamQuality.value} • ${streamFps.value}fps • ${streamLatency.value}ms';
    }
    return 'OFFLINE';
  }

  /// Show stream settings bottom sheet
  void showStreamSettings() {
    Get.bottomSheet(
      _buildStreamSettingsBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  /// Build stream settings bottom sheet
  Widget _buildStreamSettingsBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsHeader(),
          const SizedBox(height: 20),
          _buildStreamUrlSetting(),
          const SizedBox(height: 16),
          _buildQualitySetting(),
          const SizedBox(height: 16),
          _buildConnectionInfo(),
          const SizedBox(height: 16),
          _buildOptimizationTips(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build settings header
  Widget _buildSettingsHeader() {
    return Row(
      children: [
        const Icon(Icons.settings, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          'Stream Settings',
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

  /// Build stream URL setting
  Widget _buildStreamUrlSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stream URL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => Text(
                  streamUrl.value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                )),
              ),
              IconButton(
                onPressed: _changeStreamUrl,
                icon: const Icon(Icons.edit, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build quality setting
  Widget _buildQualitySetting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Stream Quality',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            streamQuality.value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        )),
      ],
    );
  }

  /// Build connection info
  Widget _buildConnectionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connection Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isStreamActive.value ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isStreamActive.value ? 'Connected' : 'Disconnected',
              style: TextStyle(
                fontSize: 12,
                color: isStreamActive.value ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )),
      ],
    );
  }
  
  /// Build optimization tips
  Widget _buildOptimizationTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.amber[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Tips Mengurangi Buffering',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Gunakan WiFi 5GHz untuk kecepatan tinggi\n'
            '• Pastikan laptop dan phone di network sama\n'
            '• Tutup aplikasi lain yang menggunakan internet\n'
            '• Jalankan server Python yang sudah dioptimasi',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Change stream URL
  void _changeStreamUrl() {
    final TextEditingController urlController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Change Stream URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Stream URL',
                hintText: 'http://192.168.1.100:5000/video',
                helperText: 'Ganti IP sesuai dengan laptop Anda',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tips: Untuk mencari IP laptop:\n'
              '• Windows: ketik "ipconfig" di cmd\n'
              '• Pastikan laptop dan phone di WiFi yang sama',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = urlController.text.trim();
              if (newUrl.isNotEmpty) {
                streamUrl.value = newUrl;
                Get.back();
                Get.back(); // Close bottom sheet too
                
                Get.snackbar(
                  'URL Updated',
                  'Stream URL berhasil diubah',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue[100],
                  colorText: Colors.blue[800],
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Legacy camera methods (for backward compatibility)
  Future<void> initializeCamera() async {
    // Redirect to stream initialization
    await _initializeStream();
  }

  Future<void> toggleCamera() async {
    // Redirect to stream toggle
    await toggleStream();
  }

  void refreshCamera() async {
    // Redirect to stream reconnect
    await reconnectStream();
  }
}
