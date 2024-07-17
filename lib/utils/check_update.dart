import 'package:flutter/material.dart';

import 'package:app_version_update/app_version_update.dart';

void verifyVersion(context) async {
  try {
    await AppVersionUpdate.checkForUpdates(
      appleId: '6479954739',
      playStoreId: 'com.dukyoung.dytimetable',
    ).then((result) async {
      if (result.canUpdate!) {
        await AppVersionUpdate.showAlertUpdate(
          appVersionResult: result,
          context: context,
          mandatory: true,
          backgroundColor: Colors.white,
          title: '새 업데이트가 있습니다.',
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 24.0),
          content: '최신 버전으로 업데이트 해주세요.',
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
          updateButtonText: '업데이트',
          updateButtonStyle: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          cancelButtonText: '나중에',
        );
      }
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}
