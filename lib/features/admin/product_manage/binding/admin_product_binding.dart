import 'package:get/get.dart';
import '../controller/admin_product_controller.dart';

class AdminProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProductController>(() => AdminProductController());
  }
}
