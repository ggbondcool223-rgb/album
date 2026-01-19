import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../main.dart';
import 'album_settings_logic.dart';

class AlbumSettingsView extends GetView<AlbumSettingsLogic> {
  const AlbumSettingsView({super.key});

  Widget _item(int index) {
    final titles = ['Clean album records', 'App version'];
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: <Widget>[
        Expanded(
            child: Text(
          titles[index],
          style: const TextStyle(color: Colors.white),
        )),
        index == 0
            ? const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 25,
              )
            : Obx(() {
                return Text(
                  controller.appVersion.value,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                );
              })
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
    )
        .decorated(
            color: const Color(0xff242c39),
            borderRadius: BorderRadius.circular(10))
        .marginOnly(bottom: 10)
        .gestures(onTap: () {
      if (index == 0) {
        controller.cleanAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: <Widget>[_item(0), _item(1)].toColumn(),
        ).marginAll(15)),
      ),
    );
  }
}
