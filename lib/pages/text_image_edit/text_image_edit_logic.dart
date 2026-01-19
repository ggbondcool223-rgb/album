import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import '../../main.dart';
import '../../db_album/data.dart';
import '../../db_album/album_entity.dart';
import '../../models/template_background.dart';

class TextImageEditLogic extends GetxController {
  final db = Get.find<AlbumDB>();
  final albumTitle = 'Untitled Album'.obs;
  final albumTags = ''.obs;
  final selectedTemplateId = Rx<int?>(null);
  final selectedMusicPath = Rx<String?>('');
  final photos = <AlbumPhotoEntity>[].obs;
  final danmakus = <AlbumDanmakuEntity>[].obs;
  final albumId = Rx<int?>(null);
  final ImagePicker picker = ImagePicker();
  final musicFiles = <String>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final currentPlayTime = 0.0.obs;
  final danmakuAnimationTime = 0.0.obs;
  final templateBackground = Rx<TemplateBackground?>(null);
  Timer? _playTimeTimer;
  Timer? _danmakuTimer;

  VoidCallback? _showEditBottomSheetCallback;

  void setShowEditBottomSheetCallback(VoidCallback? callback) {
    _showEditBottomSheetCallback = callback;
  }

  void showEditBottomSheet() {
    _showEditBottomSheetCallback?.call();
  }

  @override
  void onInit() {
    super.onInit();
    _loadMusicFiles();
    final args = Get.arguments;
    if (args != null && args['albumId'] != null) {
      albumId.value = args['albumId'];
      loadAlbum();
    } else if (args != null && args['textImages'] != null) {
      final textImages = args['textImages'] as List<Map<String, dynamic>>;
      loadTextImages(textImages);
    }
    if (args != null && args['templateId'] != null) {
      selectedTemplateId.value = args['templateId'] is int ? args['templateId'] : int.tryParse(args['templateId'].toString());
      _loadTemplateBackground();
    }
    if (selectedMusicPath.value?.isEmpty ?? true) {
      selectedMusicPath.value = musicFiles.isNotEmpty ? musicFiles.first : null;
      if (selectedMusicPath.value != null) {
        Future.microtask(() => _playMusic(selectedMusicPath.value!));
      }
    }
    _startDanmakuAnimation();
  }

  @override
  void onClose() {
    _playTimeTimer?.cancel();
    _danmakuTimer?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }

  void _loadMusicFiles() {
    try {
      final files = [
        'assets/voice1.mp3',
        'assets/voice2.mp3',
        'assets/voice3.mp3',
        'assets/voice4.mp3',
        'assets/voice5.mp3',
        'assets/voice6.mp3',
        'assets/voice7.mp3',
        'assets/voice8.mp3',
      ];
      musicFiles.value = files;
    } catch (e) {
    }
  }

  Future<void> _loadTemplateBackground() async {
    if (selectedTemplateId.value == null) return;
    try {
      final templates = await db.getTemplates();
      final template = templates.firstWhere((t) => t.id == selectedTemplateId.value);
      if (template.animationConfig != null) {
        final config = jsonDecode(template.animationConfig!);
        final animId = config['id'] as String;
        templateBackground.value = TemplateBackgroundConfig.getByTemplateId(animId);
      }
    } catch (e) {
    }
  }

  Future<void> loadAlbum() async {
    if (albumId.value == null) return;
    try {
      final albums = await db.getAlbums();
      final album = albums.firstWhere((a) => a.id == albumId.value);
      albumTitle.value = album.title;
      albumTags.value = album.tags ?? '';
      selectedTemplateId.value = album.templateId != null ? int.tryParse(album.templateId!) : null;
      selectedMusicPath.value = album.musicPath;
      
      final albumPhotos = await db.getAlbumPhotos(albumId.value!);
      photos.value = albumPhotos;
      
      final albumDanmakus = await db.getAlbumDanmakus(albumId.value!);
      danmakus.value = albumDanmakus;
      
      await _loadTemplateBackground();
      if (selectedMusicPath.value != null) {
        await _playMusic(selectedMusicPath.value!);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load album');
    }
  }

  Future<void> loadTextImages(List<Map<String, dynamic>> textImages) async {
    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final photoList = <AlbumPhotoEntity>[];
      
      for (var entry in textImages.asMap().entries) {
        final item = entry.value;
        Uint8List imageData;
        if (item['imageData'] is Uint8List) {
          imageData = item['imageData'] as Uint8List;
        } else if (item['imagePath'] is String) {
          final file = File(item['imagePath'] as String);
          imageData = await file.readAsBytes();
        } else {
          imageData = Uint8List(0);
        }
        
        photoList.add(AlbumPhotoEntity(
          albumId: 0,
          imageData: imageData,
          sortOrder: entry.key,
          subtitle: item['description'] as String?,
          createdAt: now,
        ));
      }
      
      photos.value = photoList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images');
    }
  }

  Future<void> onSaveTap() async {
    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final coverData = photos.isNotEmpty ? photos.first.imageData : null;
      final album = AlbumEntity(
        id: albumId.value,
        title: albumTitle.value,
        type: 'text_image',
        coverData: coverData,
        templateId: selectedTemplateId.value?.toString(),
        musicPath: selectedMusicPath.value,
        tags: albumTags.value.isEmpty ? null : albumTags.value,
        createdAt: albumId.value == null ? now : '',
        updatedAt: now,
      );
      
      int savedAlbumId;
      if (albumId.value == null) {
        savedAlbumId = await db.insertAlbum(album);
        albumId.value = savedAlbumId;
      } else {
        await db.updateAlbum(album);
        savedAlbumId = albumId.value!;
      }
      
      await db.deleteAlbumPhotosByAlbumId(savedAlbumId);
      for (var photo in photos) {
        await db.insertAlbumPhoto(AlbumPhotoEntity(
          albumId: savedAlbumId,
          imageData: photo.imageData,
          sortOrder: photo.sortOrder,
          subtitle: photo.subtitle,
          subtitleStyle: photo.subtitleStyle,
          filterStyle: photo.filterStyle,
          colorAdjust: photo.colorAdjust,
          cropData: photo.cropData,
          createdAt: photo.createdAt,
        ));
      }
      
      await db.deleteAlbumDanmakusByAlbumId(savedAlbumId);
      for (var danmaku in danmakus) {
        await db.insertAlbumDanmaku(AlbumDanmakuEntity(
          albumId: savedAlbumId,
          content: danmaku.content,
          timePoint: danmaku.timePoint,
          style: danmaku.style,
          createdAt: danmaku.createdAt,
        ));
      }
      
      Fluttertoast.showToast(msg: 'Album saved');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save album');
    }
  }

  Future<List<TemplateEntity>> _getTextImageTemplates() async {
    final allTemplates = await db.getTemplates();
    return allTemplates.where((t) => t.type == 'text_image').toList();
  }

  void onTemplateTap() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
        ),
        child: FutureBuilder<List<TemplateEntity>>(
          future: _getTextImageTemplates(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final templates = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.75,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final isSelected = selectedTemplateId.value == template.id;
                TemplateBackground? background;
                if (template.animationConfig != null) {
                  try {
                    final config = jsonDecode(template.animationConfig!);
                    final animId = config['id'] as String;
                    background = TemplateBackgroundConfig.getByTemplateId(animId);
                  } catch (e) {
                  }
                }
                return GestureDetector(
                  onTap: () async {
                    selectedTemplateId.value = template.id;
                    await _loadTemplateBackground();
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: background?.imagePath == null && background?.backgroundGradient != null
                          ? background?.backgroundGradient
                          : background?.imagePath == null
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF2a4d5f), Color(0xFF1a3d4f)],
                                )
                              : null,
                      color: background?.imagePath == null ? (background?.backgroundColor ?? Colors.black) : null,
                      image: background?.imagePath != null
                          ? DecorationImage(
                              image: AssetImage(background!.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12.w),
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.white.withOpacity(0.3),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (background?.imagePath == null)
                          Center(
                            child: Icon(Icons.image, color: Colors.white.withOpacity(0.5), size: 48.sp),
                          ),
                        if (isSelected)
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void onEditTap() {
  }

  void onMusicTap() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Music', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: musicFiles.length,
                itemBuilder: (context, index) {
                  final musicPath = musicFiles[index];
                  final fileName = musicPath.split('/').last;
                  final isSelected = selectedMusicPath.value == musicPath;
                  return ListTile(
                    leading: Icon(Icons.music_note, color: accentColor),
                    title: Text(fileName, style: TextStyle(color: Colors.white)),
                    trailing: isSelected ? Icon(Icons.check, color: accentColor) : null,
                    onTap: () async {
                      selectedMusicPath.value = musicPath;
                      await _playMusic(musicPath);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onAddPhotoTap() async {
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final maxSortOrder = photos.isEmpty ? 0 : photos.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b);
        photos.add(AlbumPhotoEntity(
          albumId: 0,
          imageData: imageBytes,
          sortOrder: maxSortOrder + 1,
          createdAt: now,
        ));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> onReselectPhotosTap() async {
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final photoList = <AlbumPhotoEntity>[];
        
        for (var entry in pickedFiles.asMap().entries) {
          final imageBytes = await entry.value.readAsBytes();
          photoList.add(AlbumPhotoEntity(
            albumId: 0,
            imageData: imageBytes,
            sortOrder: entry.key,
            createdAt: now,
          ));
        }
        
        photos.value = photoList;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images');
    }
  }

  void onSubtitleChanged(int index, String value) {
    if (index >= 0 && index < photos.length) {
      final photo = photos[index];
      photos[index] = AlbumPhotoEntity(
        id: photo.id,
        albumId: photo.albumId,
        imageData: photo.imageData,
        sortOrder: photo.sortOrder,
        subtitle: value.isEmpty ? null : value,
        subtitleStyle: photo.subtitleStyle,
        filterStyle: photo.filterStyle,
        colorAdjust: photo.colorAdjust,
        cropData: photo.cropData,
        createdAt: photo.createdAt,
      );
      photos.refresh();
    }
  }

  void onDeletePhotoTap(int index) {
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
      for (var i = 0; i < photos.length; i++) {
        photos[i] = AlbumPhotoEntity(
          id: photos[i].id,
          albumId: photos[i].albumId,
          imageData: photos[i].imageData,
          sortOrder: i,
          subtitle: photos[i].subtitle,
          subtitleStyle: photos[i].subtitleStyle,
          filterStyle: photos[i].filterStyle,
          colorAdjust: photos[i].colorAdjust,
          cropData: photos[i].cropData,
          createdAt: photos[i].createdAt,
        );
      }
      photos.refresh();
    }
  }

  void _updatePhotoSortOrders() {
    for (var i = 0; i < photos.length; i++) {
      photos[i] = AlbumPhotoEntity(
        id: photos[i].id,
        albumId: photos[i].albumId,
        imageData: photos[i].imageData,
        sortOrder: i,
        subtitle: photos[i].subtitle,
        subtitleStyle: photos[i].subtitleStyle,
        filterStyle: photos[i].filterStyle,
        colorAdjust: photos[i].colorAdjust,
        cropData: photos[i].cropData,
        createdAt: photos[i].createdAt,
      );
    }
  }

  void onPhotoReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    _updatePhotoSortOrders();
    photos.refresh();
  }

  Future<void> onPhotoEditTap(int index) async {
    if (index >= 0 && index < photos.length) {
      try {
        final photo = photos[index];
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        final editedImageBytes = await Get.to(() =>
          ProImageEditor.memory(
            photo.imageData,
            configs: const ProImageEditorConfigs(),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (bytes) async {
                Get.back(result: bytes);
              },
            ),
          ),
        );
        if (editedImageBytes != null && editedImageBytes is Uint8List) {
          photos[index] = AlbumPhotoEntity(
            id: photo.id,
            albumId: photo.albumId,
            imageData: editedImageBytes,
            sortOrder: photo.sortOrder,
            subtitle: photo.subtitle,
            subtitleStyle: photo.subtitleStyle,
            filterStyle: photo.filterStyle,
            colorAdjust: photo.colorAdjust,
            cropData: photo.cropData,
            createdAt: photo.createdAt,
          );
          photos.refresh();
        }
        await Future.delayed(const Duration(milliseconds: 300));
        showEditBottomSheet();
      } catch (e, stackTrace) {
        Get.snackbar('Error', 'Failed to edit image: $e');
        await Future.delayed(const Duration(milliseconds: 300));
        showEditBottomSheet();
      }
    }
  }

  Future<void> _playMusic(String musicPath) async {
    try {
      if (isPlaying.value) {
        await audioPlayer.stop();
        _playTimeTimer?.cancel();
      }
      await audioPlayer.play(AssetSource(musicPath.replaceFirst('assets/', '')));
      isPlaying.value = true;
      currentPlayTime.value = 0.0;
      _startPlayTimeTracking();
      audioPlayer.onPlayerComplete.listen((_) {
        isPlaying.value = false;
        _playTimeTimer?.cancel();
        currentPlayTime.value = 0.0;
      });
    } catch (e) {
    }
  }

  void _startPlayTimeTracking() {
    _playTimeTimer?.cancel();
    _playTimeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isPlaying.value) {
        audioPlayer.getCurrentPosition().then((position) {
          if (position != null) {
            currentPlayTime.value = position.inMilliseconds / 1000.0;
          }
        });
      }
    });
  }

  void _startDanmakuAnimation() {
    _danmakuTimer?.cancel();
    _danmakuTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (danmakus.isNotEmpty) {
        danmakuAnimationTime.value += 0.05;
        if (danmakuAnimationTime.value > 5.0) {
          danmakuAnimationTime.value = 0.0;
        }
      }
    });
  }

  Future<void> onPlayPauseTap() async {
    try {
      if (selectedMusicPath.value?.isEmpty ?? true) {
        if (musicFiles.isNotEmpty) {
          selectedMusicPath.value = musicFiles.first;
          await _playMusic(musicFiles.first);
        }
        return;
      }

      if (isPlaying.value) {
        await audioPlayer.pause();
        isPlaying.value = false;
        _playTimeTimer?.cancel();
      } else {
        await audioPlayer.resume();
        isPlaying.value = true;
        _startPlayTimeTracking();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to control music');
    }
  }

  void onAddDanmakuTap() {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    danmakus.add(AlbumDanmakuEntity(
      albumId: 0,
      content: 'New Danmaku',
      timePoint: danmakuAnimationTime.value,
      createdAt: now,
    ));
    danmakus.refresh();
    _startDanmakuAnimation();
  }

  void onDeleteDanmakuTap(int index) {
    if (index >= 0 && index < danmakus.length) {
      danmakus.removeAt(index);
      danmakus.refresh();
    }
  }

  void onDanmakuEditTap(int index) {
    if (index >= 0 && index < danmakus.length) {
      final danmaku = danmakus[index];
      Get.dialog(
        Dialog(
          backgroundColor: const Color(0xFF0B0B1E),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Danmaku', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                TextField(
                  maxLength: 10,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Content',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  controller: TextEditingController(text: danmaku.content),
                  onChanged: (value) {
                    danmakus[index] = AlbumDanmakuEntity(
                      id: danmaku.id,
                      albumId: danmaku.albumId,
                      content: value,
                      timePoint: danmaku.timePoint,
                      style: danmaku.style,
                      createdAt: danmaku.createdAt,
                    );
                    danmakus.refresh();
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Done', style: TextStyle(color: accentColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void onSaveEditTap() {
  }
}

