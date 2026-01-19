import 'package:get/get.dart';
import 'template_list_logic.dart';

class TemplateListBinding extends Bindings {
  @override
  void dependencies() {
    final templateType = Get.parameters['type'] ?? 'music';
    Get.lazyPut(() => TemplateListLogic(templateType: templateType));
  }
}

