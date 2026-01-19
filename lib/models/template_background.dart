import 'package:flutter/material.dart';

class TemplateBackground {
  final String templateId;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final String? imagePath;
  final String? videoPath;

  const TemplateBackground({
    required this.templateId,
    this.backgroundColor = const Color(0xFF0B0B1E),
    this.backgroundGradient,
    this.imagePath,
    this.videoPath,
  });
}

class TemplateBackgroundConfig {
  static List<TemplateBackground> getAll() {
    return [
      TemplateBackground(
        templateId: 'music_classic',
        imagePath: 'assets/musicBG0.png',
      ),
      TemplateBackground(
        templateId: 'music_romantic',
        imagePath: 'assets/musicBG1.png',
      ),
      TemplateBackground(
        templateId: 'music_youth',
        imagePath: 'assets/musicBG2.png',
      ),
      TemplateBackground(
        templateId: 'music_elegant',
        imagePath: 'assets/musicBG3.png',
      ),
      TemplateBackground(
        templateId: 'music_dynamic',
        imagePath: 'assets/musicBG4.png',
      ),
      TemplateBackground(
        templateId: 'text_travel',
        imagePath: 'assets/textBG0.png',
      ),
      TemplateBackground(
        templateId: 'text_life',
        imagePath: 'assets/textBG1.png',
      ),
      TemplateBackground(
        templateId: 'text_weekend',
        imagePath: 'assets/textBG2.png',
      ),
      TemplateBackground(
        templateId: 'text_story',
        imagePath: 'assets/textBG3.png',
      ),
      TemplateBackground(
        templateId: 'video_flow',
        videoPath: 'assets/videoBG0.mp4',
      ),
      TemplateBackground(
        templateId: 'video_beautiful',
        videoPath: 'assets/videoBG1.mp4',
      ),
      TemplateBackground(
        templateId: 'video_unforgettable',
        videoPath: 'assets/videoBG2.mp4',
      ),
      TemplateBackground(
        templateId: 'video_cinematic',
        videoPath: 'assets/videoBG3.mp4',
      ),
    ];
  }

  static TemplateBackground? getByTemplateId(String templateId) {
    return getAll().firstWhere(
      (bg) => bg.templateId == templateId,
      orElse: () => TemplateBackground(templateId: 'default'),
    );
  }
}

