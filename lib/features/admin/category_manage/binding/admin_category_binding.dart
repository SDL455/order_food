import 'package:get/get.dart';
import '../controller/admin_category_controller.dart';

class AdminCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminCategoryController>(() => AdminCategoryController());
  }
}
