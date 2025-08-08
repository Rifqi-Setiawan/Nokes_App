import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization of HomeController to optimize memory usage
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
