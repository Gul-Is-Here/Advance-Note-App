import 'package:get/get.dart';

import '../controllers/note_controller.dart';
import '../controllers/theme_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteController());
    Get.lazyPut(() => ThemeController());
  }
}