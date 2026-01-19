import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../album_system/album_system_logic.dart';

class AlbumSettingSave extends GetView<AlbumSystemLogic> {
  const AlbumSettingSave({super.key});


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final c = controller.webViewController;
        if (c != null) {
          if (await c.canGoBack()) {
            c.goBack();
            return false;
          }
        }
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(controller.upez.value)),
            ),
            initialSettings: InAppWebViewSettings(
              cacheEnabled: true,
            ),
            onWebViewCreated: (c) {
              controller.webViewController = c;
            },
            shouldOverrideUrlLoading: (controller1, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
        ),
      ),
    );
  }
}
