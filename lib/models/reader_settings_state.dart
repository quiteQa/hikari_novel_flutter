import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hikari_novel_flutter/models/dual_page_mode.dart';
import 'package:hikari_novel_flutter/models/reader_direction.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';

part 'reader_settings_state.freezed.dart';

@freezed
class ReaderSettingsState with _$ReaderSettingsState {
  const factory ReaderSettingsState({
    required ReaderDirection direction,
    required bool pageTurningAnimation,
    required bool wakeLock,
    required DualPageMode dualPageMode,
    required double dualPageSpacing,
    required bool immersionMode,
    required bool showStatusBar,
    required double fontSize,
    required double lineSpacing,
    required double leftMargin,
    required double topMargin,
    required double rightMargin,
    required double bottomMargin,
    required double safeAreaTop,
    required Color? textColor,
    required Color? bgColor,
    required String? textStyleFilePath,
    required String? textFamily,
    required String? bgImagePath,
    required String? readerDayBgImage,
    required String? readerNightBgImage,
    required Color? readerDayTextColor,
    required Color? readerNightTextColor,
    required Color? readerDayBgColor,
    required Color? readerNightBgColor,
  }) = _ReaderSettingsState;

  factory ReaderSettingsState.init() => ReaderSettingsState(
    direction: LocalStorageService.instance.getReaderDirection(),
    pageTurningAnimation: LocalStorageService.instance.getReaderPageTurningAnimation(),
    wakeLock: LocalStorageService.instance.getReaderWakeLock(),
    dualPageMode: LocalStorageService.instance.getReaderDualPageMode(),
    dualPageSpacing: LocalStorageService.instance.getReaderDualPageSpacing(),
    immersionMode: LocalStorageService.instance.getReaderImmersionMode(),
    showStatusBar: LocalStorageService.instance.getReaderStatusBar(),
    fontSize: LocalStorageService.instance.getReaderFontSize(),
    lineSpacing: LocalStorageService.instance.getReaderLineSpacing(),
    leftMargin: LocalStorageService.instance.getReaderLeftMargin(),
    topMargin: LocalStorageService.instance.getReaderTopMargin(),
    rightMargin: LocalStorageService.instance.getReaderRightMargin(),
    bottomMargin: LocalStorageService.instance.getReaderBottomMargin(),
    safeAreaTop: LocalStorageService.instance.getReaderSafeAreaTop() ?? 0.0,
    textColor: LocalStorageService.instance.getReaderDayTextColor(),
    bgColor: LocalStorageService.instance.getReaderDayBgColor(),
    textStyleFilePath: LocalStorageService.instance.getReaderTextStyleFilePath(),
    textFamily: LocalStorageService.instance.getReaderTextFamily(),
    bgImagePath: LocalStorageService.instance.getReaderDayBgImage(),
    readerDayBgImage: LocalStorageService.instance.getReaderDayBgImage(),
    readerNightBgImage: LocalStorageService.instance.getReaderNightBgImage(),
    readerDayTextColor: LocalStorageService.instance.getReaderDayTextColor(),
    readerNightTextColor: LocalStorageService.instance.getReaderNightTextColor(),
    readerDayBgColor: LocalStorageService.instance.getReaderDayBgColor(),
    readerNightBgColor: LocalStorageService.instance.getReaderNightBgColor(),
  );
}