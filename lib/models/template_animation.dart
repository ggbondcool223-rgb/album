class TemplateAnimation {
  final String id;
  final String name;
  final String type;
  final TemplateAnimationStyle imageAnimation;
  final TemplateAnimationStyle subtitleAnimation;
  final TemplateAnimationStyle danmakuAnimation;
  final Duration transitionDuration;
  final String? description;

  const TemplateAnimation({
    required this.id,
    required this.name,
    required this.type,
    required this.imageAnimation,
    required this.subtitleAnimation,
    required this.danmakuAnimation,
    required this.transitionDuration,
    this.description,
  });
}

enum TemplateAnimationStyle {
  fade,
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  zoomIn,
  zoomOut,
  rotate,
  flip,
  bounce,
  elastic,
  none,
}

class TemplateAnimationConfig {
  static List<TemplateAnimation> getMusicTemplates() {
    return [
      TemplateAnimation(
        id: 'music_classic',
        name: 'Classic Memories',
        type: 'music',
        imageAnimation: TemplateAnimationStyle.fade,
        subtitleAnimation: TemplateAnimationStyle.slideUp,
        danmakuAnimation: TemplateAnimationStyle.slideRight,
        transitionDuration: const Duration(milliseconds: 800),
      ),
      TemplateAnimation(
        id: 'music_romantic',
        name: 'Romantic Time',
        type: 'music',
        imageAnimation: TemplateAnimationStyle.zoomIn,
        subtitleAnimation: TemplateAnimationStyle.fade,
        danmakuAnimation: TemplateAnimationStyle.slideLeft,
        transitionDuration: const Duration(milliseconds: 1000),
      ),
      TemplateAnimation(
        id: 'music_youth',
        name: 'Youth Memory',
        type: 'music',
        imageAnimation: TemplateAnimationStyle.slideLeft,
        subtitleAnimation: TemplateAnimationStyle.slideRight,
        danmakuAnimation: TemplateAnimationStyle.slideRight,
        transitionDuration: const Duration(milliseconds: 600),
      ),
      TemplateAnimation(
        id: 'music_elegant',
        name: 'Elegant Flow',
        type: 'music',
        imageAnimation: TemplateAnimationStyle.rotate,
        subtitleAnimation: TemplateAnimationStyle.zoomIn,
        danmakuAnimation: TemplateAnimationStyle.slideLeft,
        transitionDuration: const Duration(milliseconds: 900),
      ),
      TemplateAnimation(
        id: 'music_dynamic',
        name: 'Dynamic Rhythm',
        type: 'music',
        imageAnimation: TemplateAnimationStyle.flip,
        subtitleAnimation: TemplateAnimationStyle.bounce,
        danmakuAnimation: TemplateAnimationStyle.slideLeft,
        transitionDuration: const Duration(milliseconds: 700),
      ),
    ];
  }

  static List<TemplateAnimation> getTextImageTemplates() {
    return [
      TemplateAnimation(
        id: 'text_travel',
        name: 'Travel Diary',
        type: 'text_image',
        imageAnimation: TemplateAnimationStyle.slideUp,
        subtitleAnimation: TemplateAnimationStyle.fade,
        danmakuAnimation: TemplateAnimationStyle.none,
        transitionDuration: const Duration(milliseconds: 800),
      ),
      TemplateAnimation(
        id: 'text_life',
        name: 'Life Moments',
        type: 'text_image',
        imageAnimation: TemplateAnimationStyle.zoomIn,
        subtitleAnimation: TemplateAnimationStyle.slideLeft,
        danmakuAnimation: TemplateAnimationStyle.none,
        transitionDuration: const Duration(milliseconds: 900),
      ),
      TemplateAnimation(
        id: 'text_weekend',
        name: 'Weekend Time',
        type: 'text_image',
        imageAnimation: TemplateAnimationStyle.fade,
        subtitleAnimation: TemplateAnimationStyle.zoomOut,
        danmakuAnimation: TemplateAnimationStyle.none,
        transitionDuration: const Duration(milliseconds: 700),
      ),
      TemplateAnimation(
        id: 'text_story',
        name: 'Story Book',
        type: 'text_image',
        imageAnimation: TemplateAnimationStyle.flip,
        subtitleAnimation: TemplateAnimationStyle.slideRight,
        danmakuAnimation: TemplateAnimationStyle.none,
        transitionDuration: const Duration(milliseconds: 850),
      ),
    ];
  }

  static List<TemplateAnimation> getVideoTemplates() {
    return [
      TemplateAnimation(
        id: 'video_flow',
        name: 'Time Flow',
        type: 'video',
        imageAnimation: TemplateAnimationStyle.slideLeft,
        subtitleAnimation: TemplateAnimationStyle.fade,
        danmakuAnimation: TemplateAnimationStyle.slideRight,
        transitionDuration: const Duration(milliseconds: 500),
      ),
      TemplateAnimation(
        id: 'video_beautiful',
        name: 'Beautiful Start',
        type: 'video',
        imageAnimation: TemplateAnimationStyle.zoomIn,
        subtitleAnimation: TemplateAnimationStyle.slideUp,
        danmakuAnimation: TemplateAnimationStyle.slideLeft,
        transitionDuration: const Duration(milliseconds: 600),
      ),
      TemplateAnimation(
        id: 'video_unforgettable',
        name: 'Unforgettable Memory',
        type: 'video',
        imageAnimation: TemplateAnimationStyle.fade,
        subtitleAnimation: TemplateAnimationStyle.zoomIn,
        danmakuAnimation: TemplateAnimationStyle.slideRight,
        transitionDuration: const Duration(milliseconds: 650),
      ),
      TemplateAnimation(
        id: 'video_cinematic',
        name: 'Cinematic Magic',
        type: 'video',
        imageAnimation: TemplateAnimationStyle.rotate,
        subtitleAnimation: TemplateAnimationStyle.slideDown,
        danmakuAnimation: TemplateAnimationStyle.slideLeft,
        transitionDuration: const Duration(milliseconds: 550),
      ),
    ];
  }

  static TemplateAnimation? getTemplateById(String id) {
    final all = [
      ...getMusicTemplates(),
      ...getTextImageTemplates(),
      ...getVideoTemplates(),
    ];
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}

