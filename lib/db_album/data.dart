import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'album_entity.dart';

class AlbumDB extends GetxService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'album.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE album_photos RENAME TO album_photos_old');
      await db.execute('''
        CREATE TABLE album_photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          album_id INTEGER NOT NULL,
          image_data BLOB NOT NULL,
          sort_order INTEGER NOT NULL,
          subtitle TEXT,
          subtitle_style TEXT,
          filter_style TEXT,
          color_adjust TEXT,
          crop_data TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('DROP TABLE album_photos_old');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE albums RENAME TO albums_old');
      await db.execute('''
        CREATE TABLE albums (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          cover_data BLOB,
          template_id TEXT,
          music_path TEXT,
          category_id INTEGER,
          tags TEXT,
          video_path TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');
      await db.execute('DROP TABLE albums_old');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        cover_data BLOB,
        template_id TEXT,
        music_path TEXT,
        category_id INTEGER,
        tags TEXT,
        video_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE album_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        image_data BLOB NOT NULL,
        sort_order INTEGER NOT NULL,
        subtitle TEXT,
        subtitle_style TEXT,
        filter_style TEXT,
        color_adjust TEXT,
        crop_data TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE album_danmakus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        time_point REAL NOT NULL,
        style TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE album_text_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        sort_order INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE album_scenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        subtitle TEXT,
        subtitle_style TEXT,
        scene_order INTEGER NOT NULL,
        duration REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        preview_path TEXT,
        animation_config TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        album_ids TEXT NOT NULL,
        play_mode TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  String _getCurrentTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  Future<List<AlbumEntity>> getAlbums({String? categoryId}) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps;
      if (categoryId != null) {
        maps = await db.query(
          'albums',
          where: 'category_id = ?',
          whereArgs: [categoryId],
          orderBy: 'created_at DESC, id DESC',
        );
      } else {
        maps = await db.query(
          'albums',
          orderBy: 'created_at DESC, id DESC',
        );
      }
      return maps.map((map) => AlbumEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAlbum(AlbumEntity album) async {
    try {
      final db = await database;
      return await db.insert('albums', album.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateAlbum(AlbumEntity album) async {
    try {
      final db = await database;
      final updatedAlbum = AlbumEntity(
        id: album.id,
        title: album.title,
        type: album.type,
        coverData: album.coverData,
        templateId: album.templateId,
        musicPath: album.musicPath,
        categoryId: album.categoryId,
        tags: album.tags,
        videoPath: album.videoPath,
        createdAt: album.createdAt,
        updatedAt: _getCurrentTime(),
      );
      return await db.update(
        'albums',
        updatedAlbum.toMap(),
        where: 'id = ?',
        whereArgs: [album.id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbum(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'albums',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<List<AlbumPhotoEntity>> getAlbumPhotos(int albumId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'album_photos',
        where: 'album_id = ?',
        whereArgs: [albumId],
        orderBy: 'sort_order ASC, id ASC',
      );
      return maps.map((map) => AlbumPhotoEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAlbumPhoto(AlbumPhotoEntity photo) async {
    try {
      final db = await database;
      return await db.insert('album_photos', photo.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateAlbumPhoto(AlbumPhotoEntity photo) async {
    try {
      final db = await database;
      return await db.update(
        'album_photos',
        photo.toMap(),
        where: 'id = ?',
        whereArgs: [photo.id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumPhoto(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'album_photos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumPhotosByAlbumId(int albumId) async {
    try {
      final db = await database;
      return await db.delete(
        'album_photos',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<List<AlbumDanmakuEntity>> getAlbumDanmakus(int albumId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'album_danmakus',
        where: 'album_id = ?',
        whereArgs: [albumId],
        orderBy: 'time_point ASC, id ASC',
      );
      return maps.map((map) => AlbumDanmakuEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAlbumDanmaku(AlbumDanmakuEntity danmaku) async {
    try {
      final db = await database;
      return await db.insert('album_danmakus', danmaku.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumDanmaku(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'album_danmakus',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumDanmakusByAlbumId(int albumId) async {
    try {
      final db = await database;
      return await db.delete(
        'album_danmakus',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<List<AlbumTextImageEntity>> getAlbumTextImages(int albumId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'album_text_images',
        where: 'album_id = ?',
        whereArgs: [albumId],
        orderBy: 'sort_order ASC, id ASC',
      );
      return maps.map((map) => AlbumTextImageEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAlbumTextImage(AlbumTextImageEntity textImage) async {
    try {
      final db = await database;
      return await db.insert('album_text_images', textImage.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateAlbumTextImage(AlbumTextImageEntity textImage) async {
    try {
      final db = await database;
      return await db.update(
        'album_text_images',
        textImage.toMap(),
        where: 'id = ?',
        whereArgs: [textImage.id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumTextImage(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'album_text_images',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumTextImagesByAlbumId(int albumId) async {
    try {
      final db = await database;
      return await db.delete(
        'album_text_images',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<List<AlbumSceneEntity>> getAlbumScenes(int albumId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'album_scenes',
        where: 'album_id = ?',
        whereArgs: [albumId],
        orderBy: 'scene_order ASC, id ASC',
      );
      return maps.map((map) => AlbumSceneEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertAlbumScene(AlbumSceneEntity scene) async {
    try {
      final db = await database;
      return await db.insert('album_scenes', scene.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateAlbumScene(AlbumSceneEntity scene) async {
    try {
      final db = await database;
      return await db.update(
        'album_scenes',
        scene.toMap(),
        where: 'id = ?',
        whereArgs: [scene.id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteAlbumScenesByAlbumId(int albumId) async {
    try {
      final db = await database;
      return await db.delete(
        'album_scenes',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<List<CategoryEntity>> getCategories() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'categories',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => CategoryEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertCategory(CategoryEntity category) async {
    try {
      final db = await database;
      return await db.insert('categories', category.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<List<TemplateEntity>> getTemplates({String? type}) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps;
      if (type != null) {
        maps = await db.query(
          'templates',
          where: 'type = ?',
          whereArgs: [type],
          orderBy: 'is_favorite DESC, created_at DESC, id DESC',
        );
      } else {
        maps = await db.query(
          'templates',
          orderBy: 'is_favorite DESC, created_at DESC, id DESC',
        );
      }
      return maps.map((map) => TemplateEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TemplateEntity>> getFavoriteTemplates() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'templates',
        where: 'is_favorite = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => TemplateEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertTemplate(TemplateEntity template) async {
    try {
      final db = await database;
      return await db.insert('templates', template.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateTemplateFavorite(int id, bool isFavorite) async {
    try {
      final db = await database;
      return await db.update(
        'templates',
        {'is_favorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<List<PlaylistEntity>> getPlaylists() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'playlists',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => PlaylistEntity.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> insertPlaylist(PlaylistEntity playlist) async {
    try {
      final db = await database;
      return await db.insert('playlists', playlist.toMap());
    } catch (e) {
      return 0;
    }
  }

  Future<int> deletePlaylist(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'playlists',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  Future<void> cleanAllData () async {
    try {
      final db = await database;
      await db.delete('albums');
      await db.delete('album_photos');
      await db.delete('album_danmakus');
    } catch (e) {
      return;
    }
  }
}

