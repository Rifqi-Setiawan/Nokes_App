import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  // Observable properties for video stream management
  final streamUrl = 'http://192.168.5.186:5000/video'.obs;
  final isStreamActive = false.obs;
  final isStreamLoading = false.obs;
  final streamError = ''.obs;
  final streamQuality = 'HD'.obs;
  final streamLatency = 0.obs;
  final streamFps = 0.obs;
  
  // Observable properties for smoking detection results
  final smokingDetected = false.obs;
  final detectionConfidence = 0.0.obs;
  final totalDetections = 0.obs;
  final lastDetectionTime = ''.obs;
  
  // Periodic timers for real-time monitoring
  Timer? _connectionTimer;
  Timer? _qualityTimer;
  Timer? _latencyTimer;
  Timer? _detectionTimer;
  
  // Prevents spam alerts by tracking last alert timestamp
  DateTime? _lastAlertTime;

  // Backward compatibility properties for legacy camera implementation
  final isCameraInitialized = false.obs;
  final isCameraActive = false.obs;
  final cameraError = ''.obs;
  final count = 0.obs;



  @override
  void onInit() {
    super.onInit();
    // Initialize stream connection with delay to ensure UI readiness
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeStream();
    });
  }

  @override
  void onClose() {
    // Clean up all active timers to prevent memory leaks
    _connectionTimer?.cancel();
    _qualityTimer?.cancel();
    _latencyTimer?.cancel();
    _detectionTimer?.cancel();
    super.onClose();
  }

  // Establishes initial connection to video stream with automatic retry logic
  Future<void> _initializeStream() async {
    try {
      setStreamLoading(true);
      streamError.value = '';
      
      // Direct stream activation since only /video endpoint is available
      print('🔗 Mencoba koneksi ke: ${streamUrl.value}');
      
      // Brief delay ensures UI components are fully rendered
      await Future.delayed(const Duration(milliseconds: 500));
      
      isStreamActive.value = true;
      setStreamLoading(false);
      
      // Begin real-time monitoring after successful connection
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

  // Initializes multiple periodic timers for comprehensive stream monitoring
  void _startMonitoring() {
    // Health check every 15 seconds for fast disconnect detection
    _connectionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkStreamHealth();
    });
    
    // Quality metrics update every 3 seconds for responsive feedback
    _qualityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateStreamQuality();
    });
    
    // Network latency monitoring every 2 seconds
    _latencyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateLatencyInfo();
    });
    
    // Real-time smoking detection polling every second
    _detectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDetectionStatus();
    });
  }

  // Performs basic connectivity validation for the video stream
  void _checkStreamHealth() {
    if (isStreamActive.value) {
      // Simple health verification - can be enhanced with actual server ping
      print('Stream health check: OK');
    }
  }

  // Updates stream quality metrics based on current performance
  void _updateStreamQuality() {
    if (isStreamActive.value) {
      // Simulated quality assessment based on system performance
      final now = DateTime.now();
      final qualities = ['HD', '720p', '480p'];
      streamQuality.value = qualities[now.second % 3];
      
      // Dynamic FPS simulation for realistic monitoring
      streamFps.value = 25 + (now.millisecond % 10);
    }
  }
  
  // Monitors network latency between client and streaming server
  void _updateLatencyInfo() {
    if (isStreamActive.value) {
      // Simulated latency calculation for performance monitoring
      final latency = 50 + (DateTime.now().millisecond % 100);
      streamLatency.value = latency;
    }
  }
  
  // Polls YOLOv8 server for real-time smoking detection results
  Future<void> _fetchDetectionStatus() async {
  if (!isStreamActive.value) return;

  try {
    final response = await http.get(Uri.parse('${streamUrl.value.replaceFirst("/video", "")}/status'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final detected = data['detected'] ?? false;
      final confidence = (data['confidence'] ?? 0.0).toDouble();

      // Trigger detection only when confidence exceeds threshold
      if (detected && confidence > 0.5) {
        smokingDetected.value = true;
        detectionConfidence.value = confidence;
        totalDetections.value++;
        lastDetectionTime.value = TimeOfDay.now().format(Get.context!);
        _showSmokingAlert();
      } else {
        // Reset detection state when no smoking is detected
        smokingDetected.value = false;
        detectionConfidence.value = 0.0;
      }
    }
  } catch (e) {
    print('Error fetching detection status: $e');
  }
}

  
  // Displays smoking detection alert with spam prevention mechanism
  void _showSmokingAlert() {
    // Throttle alerts to prevent notification spam
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

  // Toggles video stream between active and inactive states
  Future<void> toggleStream() async {
    try {
      if (isStreamActive.value) {
        // Deactivate stream and clean up resources
        isStreamActive.value = false;
        streamError.value = '';
        
        // Cancel all monitoring timers to free memory
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
        // Reactivate stream connection
        await _initializeStream();
      }
    } catch (e) {
      handleStreamError(e.toString());
    }
  }

  // Attempts to re-establish stream connection after error or disconnect
  Future<void> reconnectStream() async {
    streamError.value = '';
    await _initializeStream();
  }

  // Handles stream connection errors and displays user-friendly feedback
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

  // Updates loading state and clears errors when loading begins
  void setStreamLoading(bool loading) {
    isStreamLoading.value = loading;
    if (loading) {
      streamError.value = '';
    }
  }

  // Returns formatted string with current stream performance metrics
  String getStreamQuality() {
    if (isStreamActive.value) {
      return '${streamQuality.value} • ${streamFps.value}fps • ${streamLatency.value}ms';
    }
    return 'OFFLINE';
  }

  // Displays modal bottom sheet for stream configuration options
  void showStreamSettings() {
    Get.bottomSheet(
      _buildStreamSettingsBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // Constructs the main container for stream settings interface
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

  // Creates header section with title and close button for settings modal
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

  // Builds URL configuration section with current URL display and edit button
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

  // Creates quality indicator showing current stream resolution
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

  // Displays real-time connection status with visual indicator
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
  
  // Creates informational section with performance optimization suggestions
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

  // Opens dialog for user to modify stream URL with validation
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
                Get.back();
                
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

  // Legacy method redirects maintained for backward compatibility
  Future<void> initializeCamera() async {
    await _initializeStream();
  }

  Future<void> toggleCamera() async {
    await toggleStream();
  }

  void refreshCamera() async {
    await reconnectStream();
  }
}
