import 'dart:typed_data';

class AlbumEntity {
  final int? id;
  final String title;
  final String type;
  final Uint8List? coverData;
  final String? templateId;
  final String? musicPath;
  final String? categoryId;
  final String? tags;
  final String? videoPath;
  final String createdAt;
  final String? updatedAt;

  const AlbumEntity({
    this.id,
    required this.title,
    required this.type,
    this.coverData,
    this.templateId,
    this.musicPath,
    this.categoryId,
    this.tags,
    this.videoPath,
    required this.createdAt,
    this.updatedAt,
  });

  factory AlbumEntity.fromMap(Map<String, dynamic> map) {
    Uint8List? coverData;
    if (map['cover_data'] is List<int>) {
      coverData = Uint8List.fromList(map['cover_data'] as List<int>);
    } else if (map['cover_data'] is Uint8List) {
      coverData = map['cover_data'] as Uint8List;
    } else {
      coverData = null;
    }
    
    return AlbumEntity(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: map['type'] as String,
      coverData: coverData,
      templateId: map['template_id'] as String?,
      musicPath: map['music_path'] as String?,
      categoryId: map['category_id'] as String?,
      tags: map['tags'] as String?,
      videoPath: map['video_path'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'type': type,
      'cover_data': coverData,
      'template_id': templateId,
      'music_path': musicPath,
      'category_id': categoryId,
      'tags': tags,
      'video_path': videoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AlbumPhotoEntity {
  final int? id;
  final int albumId;
  final Uint8List imageData;
  final int sortOrder;
  final String? subtitle;
  final String? subtitleStyle;
  final String? filterStyle;
  final String? colorAdjust;
  final String? cropData;
  final String createdAt;

  const AlbumPhotoEntity({
    this.id,
    required this.albumId,
    required this.imageData,
    required this.sortOrder,
    this.subtitle,
    this.subtitleStyle,
    this.filterStyle,
    this.colorAdjust,
    this.cropData,
    required this.createdAt,
  });

  factory AlbumPhotoEntity.fromMap(Map<String, dynamic> map) {
    Uint8List imageData;
    if (map['image_data'] is List<int>) {
      imageData = Uint8List.fromList(map['image_data'] as List<int>);
    } else if (map['image_data'] is Uint8List) {
      imageData = map['image_data'] as Uint8List;
    } else {
      imageData = Uint8List(0);
    }
    
    return AlbumPhotoEntity(
      id: map['id'] as int?,
      albumId: map['album_id'] as int,
      imageData: imageData,
      sortOrder: map['sort_order'] as int,
      subtitle: map['subtitle'] as String?,
      subtitleStyle: map['subtitle_style'] as String?,
      filterStyle: map['filter_style'] as String?,
      colorAdjust: map['color_adjust'] as String?,
      cropData: map['crop_data'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'album_id': albumId,
      'image_data': imageData,
      'sort_order': sortOrder,
      'subtitle': subtitle,
      'subtitle_style': subtitleStyle,
      'filter_style': filterStyle,
      'color_adjust': colorAdjust,
      'crop_data': cropData,
      'created_at': createdAt,
    };
  }
}

class AlbumDanmakuEntity {
  final int? id;
  final int albumId;
  final String content;
  final double timePoint;
  final String? style;
  final String createdAt;

  const AlbumDanmakuEntity({
    this.id,
    required this.albumId,
    required this.content,
    required this.timePoint,
    this.style,
    required this.createdAt,
  });

  factory AlbumDanmakuEntity.fromMap(Map<String, dynamic> map) {
    return AlbumDanmakuEntity(
      id: map['id'] as int?,
      albumId: map['album_id'] as int,
      content: map['content'] as String,
      timePoint: map['time_point'] as double,
      style: map['style'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'album_id': albumId,
      'content': content,
      'time_point': timePoint,
      'style': style,
      'created_at': createdAt,
    };
  }
}

class AlbumTextImageEntity {
  final int? id;
  final int albumId;
  final String imagePath;
  final String? description;
  final int sortOrder;
  final String createdAt;

  const AlbumTextImageEntity({
    this.id,
    required this.albumId,
    required this.imagePath,
    this.description,
    required this.sortOrder,
    required this.createdAt,
  });

  factory AlbumTextImageEntity.fromMap(Map<String, dynamic> map) {
    return AlbumTextImageEntity(
      id: map['id'] as int?,
      albumId: map['album_id'] as int,
      imagePath: map['image_path'] as String,
      description: map['description'] as String?,
      sortOrder: map['sort_order'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'album_id': albumId,
      'image_path': imagePath,
      'description': description,
      'sort_order': sortOrder,
      'created_at': createdAt,
    };
  }
}

class AlbumSceneEntity {
  final int? id;
  final int albumId;
  final String imagePath;
  final String? subtitle;
  final String? subtitleStyle;
  final int sceneOrder;
  final double? duration;
  final String createdAt;

  const AlbumSceneEntity({
    this.id,
    required this.albumId,
    required this.imagePath,
    this.subtitle,
    this.subtitleStyle,
    required this.sceneOrder,
    this.duration,
    required this.createdAt,
  });

  factory AlbumSceneEntity.fromMap(Map<String, dynamic> map) {
    return AlbumSceneEntity(
      id: map['id'] as int?,
      albumId: map['album_id'] as int,
      imagePath: map['image_path'] as String,
      subtitle: map['subtitle'] as String?,
      subtitleStyle: map['subtitle_style'] as String?,
      sceneOrder: map['scene_order'] as int,
      duration: map['duration'] as double?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'album_id': albumId,
      'image_path': imagePath,
      'subtitle': subtitle,
      'subtitle_style': subtitleStyle,
      'scene_order': sceneOrder,
      'duration': duration,
      'created_at': createdAt,
    };
  }
}

class CategoryEntity {
  final int? id;
  final String name;
  final String createdAt;

  const CategoryEntity({
    this.id,
    required this.name,
    required this.createdAt,
  });

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt,
    };
  }
}

class TemplateEntity {
  final int? id;
  final String name;
  final String type;
  final String? previewPath;
  final String? animationConfig;
  final bool isFavorite;
  final String createdAt;

  const TemplateEntity({
    this.id,
    required this.name,
    required this.type,
    this.previewPath,
    this.animationConfig,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory TemplateEntity.fromMap(Map<String, dynamic> map) {
    return TemplateEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      previewPath: map['preview_path'] as String?,
      animationConfig: map['animation_config'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'preview_path': previewPath,
      'animation_config': animationConfig,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt,
    };
  }
}

class PlaylistEntity {
  final int? id;
  final String name;
  final String albumIds;
  final String playMode;
  final String createdAt;

  const PlaylistEntity({
    this.id,
    required this.name,
    required this.albumIds,
    required this.playMode,
    required this.createdAt,
  });

  factory PlaylistEntity.fromMap(Map<String, dynamic> map) {
    return PlaylistEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      albumIds: map['album_ids'] as String,
      playMode: map['play_mode'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'album_ids': albumIds,
      'play_mode': playMode,
      'created_at': createdAt,
    };
  }
}

