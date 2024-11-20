
import 'package:get/get.dart';

import 'network_controller.dart';

class DependencyInjection{
  static void init(){
    Get.put<NetworkController>(NetworkController(),permanent:true);
  }
}