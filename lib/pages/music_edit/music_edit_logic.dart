import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../main.dart';
import '../../db_album/data.dart';
import '../../db_album/album_entity.dart';
import '../../models/template_animation.dart';
import '../../models/template_background.dart';

class MusicEditLogic extends GetxController {
  final db = Get.find<AlbumDB>();
  final albumTitle = 'Untitled Album'.obs;
  final albumTags = ''.obs;
  final selectedTemplateId = Rx<int?>(null);
  final selectedMusicPath = Rx<String?>('');
  final photos = <AlbumPhotoEntity>[].obs;
  final danmakus = <AlbumDanmakuEntity>[].obs;
  final albumId = Rx<int?>(null);
  final editMode = 'photo'.obs;
  final historyStack = <List<AlbumPhotoEntity>>[].obs;
  final historyIndex = 0.obs;
  final ImagePicker picker = ImagePicker();
  final musicFiles = <String>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final currentPhotoIndex = 0.obs;
  final templateAnimation = Rx<TemplateAnimation?>(null);
  final templateBackground = Rx<TemplateBackground?>(null);
  final showEditSection = false.obs;
  final editingPhotoIndex = Rx<int?>(null);
  final animationUpdateKey = 0.obs;
  final currentPlayTime = 0.0.obs;
  final danmakuAnimationTime = 0.0.obs;
  Timer? _photoSwitchTimer;
  Timer? _playTimeTimer;
  Timer? _danmakuTimer;

  @override
  void onInit() {
    super.onInit();
    _loadMusicFiles();
    final args = Get.arguments;
    if (args != null && args['albumId'] != null) {
      albumId.value = args['albumId'];
      loadAlbum();
    } else if (args != null && args['imageBytes'] != null) {
      final imageBytes = args['imageBytes'] as List<Uint8List>;
      loadImages(imageBytes);
    }
    if (args != null && args['templateId'] != null) {
      selectedTemplateId.value = args['templateId'] is int ? args['templateId'] : int.tryParse(args['templateId'].toString());
      _loadTemplateAnimation();
    }
    if (selectedMusicPath.value?.isEmpty ?? true) {
      selectedMusicPath.value = musicFiles.isNotEmpty ? musicFiles.first : null;
      if (selectedMusicPath.value != null) {
        Future.microtask(() => _playMusic(selectedMusicPath.value!));
      }
    }
    _saveHistory();
    // _startPhotoAutoSwitch() will be called after photos are loaded in loadAlbum() or loadImages()
    _startDanmakuAnimation();
  }

  @override
  void onClose() {
    _photoSwitchTimer?.cancel();
    _playTimeTimer?.cancel();
    _danmakuTimer?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }

  void _startPhotoAutoSwitch() {
    _photoSwitchTimer?.cancel();
    if (photos.isEmpty || photos.length <= 1) return;
    
    final animation = templateAnimation.value;
    final duration = animation?.transitionDuration ?? const Duration(seconds: 3);
    
    _photoSwitchTimer = Timer.periodic(duration, (timer) {
      if (photos.isEmpty || photos.length <= 1) {
        timer.cancel();
        return;
      }
      
      if (currentPhotoIndex.value < photos.length - 1) {
        currentPhotoIndex.value++;
      } else {
        currentPhotoIndex.value = 0;
      }
      triggerAnimationUpdate();
    });
  }

  Future<void> _loadTemplateAnimation() async {
    if (selectedTemplateId.value == null) return;
    try {
      final templates = await db.getTemplates();
      final template = templates.firstWhere((t) => t.id == selectedTemplateId.value);
      if (template.animationConfig != null) {
        final config = jsonDecode(template.animationConfig!);
        final animId = config['id'] as String;
        templateAnimation.value = TemplateAnimationConfig.getTemplateById(animId);
        templateBackground.value = TemplateBackgroundConfig.getByTemplateId(animId);
      }
    } catch (e) {
    }
  }

  void onEditModeToggle() {
    showEditSection.value = !showEditSection.value;
  }

  VoidCallback? _showEditBottomSheetCallback;

  void setShowEditBottomSheetCallback(VoidCallback? callback) {
    _showEditBottomSheetCallback = callback;
  }

  void showEditBottomSheet() {
    _showEditBottomSheetCallback?.call();
  }

  void triggerAnimationUpdate() {
    animationUpdateKey.value++;
  }

  void onSaveEditTap() {
    _saveHistory();
    showEditSection.value = false;
  }

  void onUndoTap() {
    if (historyIndex.value > 0) {
      historyIndex.value--;
      photos.value = List.from(historyStack[historyIndex.value]);
    } else {
      Get.snackbar('Info', 'No more undo available');
    }
  }

  void onRedoTap() {
    if (historyIndex.value < historyStack.length - 1) {
      historyIndex.value++;
      photos.value = List.from(historyStack[historyIndex.value]);
    } else {
      Get.snackbar('Info', 'No more redo available');
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
      currentPhotoIndex.value = 0;
      
      final albumDanmakus = await db.getAlbumDanmakus(albumId.value!);
      danmakus.value = albumDanmakus;
      
      await _loadTemplateAnimation();
      if (selectedMusicPath.value != null) {
        await _playMusic(selectedMusicPath.value!);
      }
      
      _startPhotoAutoSwitch();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load album');
    }
  }

  Future<void> loadImages(List<Uint8List> imageBytesList) async {
    try {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      photos.value = imageBytesList.asMap().entries.map((entry) {
      return AlbumPhotoEntity(
        albumId: 0,
          imageData: entry.value,
        sortOrder: entry.key,
        createdAt: now,
      );
    }).toList();
      currentPhotoIndex.value = 0;
      _saveHistory();
      _startPhotoAutoSwitch();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images');
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
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to control music');
    }
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
      Get.snackbar('Error', 'Failed to load music files');
    }
  }

  void _saveHistory() {
    if (historyIndex.value < historyStack.length - 1) {
      historyStack.removeRange(historyIndex.value + 1, historyStack.length);
    }
    historyStack.add(List.from(photos));
    if (historyStack.length > 10) {
      historyStack.removeAt(0);
    } else {
      historyIndex.value = historyStack.length - 1;
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

  Future<void> onSaveTap() async {
    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final coverData = photos.isNotEmpty ? photos.first.imageData : null;
      final album = AlbumEntity(
        id: albumId.value,
        title: albumTitle.value,
        type: 'music',
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
          future: _getMusicTemplates(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final templates = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Template', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
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
                          await _loadTemplateAnimation();
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
                                        colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
                                      )
                                    : null,
                            color: background?.imagePath == null
                                ? (background?.backgroundColor ?? Colors.black)
                                : null,
                            image: background?.imagePath != null
                                ? DecorationImage(
                                    image: AssetImage(background!.imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12.w),
                            border: Border.all(
                              color: isSelected ? accentColor : Colors.transparent,
                              width: isSelected ? 3 : 0,
                            ),
                          ),
                          child: Stack(
                            children: [
                              if (background?.imagePath == null)
                                Center(
                                  child: Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 48.sp,
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(12.w),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          template.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: accentColor,
                                          size: 20.sp,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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

  void onEditModeTap(String mode) {
    editMode.value = mode;
  }

  Future<List<TemplateEntity>> _getMusicTemplates() async {
    final allTemplates = await db.getTemplates();
    return allTemplates.where((t) => t.type == 'music').toList();
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
        photos.refresh();
        triggerAnimationUpdate();
        _saveHistory();
        _startPhotoAutoSwitch();
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
        
        for (var i = 0; i < pickedFiles.length; i++) {
          final imageBytes = await pickedFiles[i].readAsBytes();
          photoList.add(AlbumPhotoEntity(
            albumId: 0,
            imageData: imageBytes,
            sortOrder: i,
            createdAt: now,
          ));
        }
        
        photos.value = photoList;
        currentPhotoIndex.value = 0;
        photos.refresh();
        triggerAnimationUpdate();
        _saveHistory();
        _startPhotoAutoSwitch();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images');
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
      if (currentPhotoIndex.value >= photos.length && photos.isNotEmpty) {
        currentPhotoIndex.value = photos.length - 1;
      } else if (photos.isEmpty) {
        currentPhotoIndex.value = 0;
      }
      photos.refresh();
      triggerAnimationUpdate();
      _saveHistory();
      _startPhotoAutoSwitch();
    }
  }

  void onPhotoMoveUp(int index) {
    if (index > 0) {
      final temp = photos[index];
      photos[index] = photos[index - 1];
      photos[index - 1] = temp;
      _updatePhotoSortOrders();
      _saveHistory();
    }
  }

  void onPhotoMoveDown(int index) {
    if (index < photos.length - 1) {
      final temp = photos[index];
      photos[index] = photos[index + 1];
      photos[index + 1] = temp;
      _updatePhotoSortOrders();
      _saveHistory();
    }
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
          update(['photo']);
          triggerAnimationUpdate();
          _saveHistory();
        }
        await Future.delayed(const Duration(milliseconds: 300));
        showEditBottomSheet();
      } catch (e, stackTrace) {
        print('onPhotoEditTap error: $e');
        print('Stack trace: $stackTrace');
        Get.snackbar('Error', 'Failed to edit image: $e');
        await Future.delayed(const Duration(milliseconds: 300));
        showEditBottomSheet();
      }
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
      if (currentPhotoIndex.value == index) {
        triggerAnimationUpdate();
      }
    }
  }

  void onPhotoReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    _updatePhotoSortOrders();
    if (currentPhotoIndex.value == oldIndex) {
      currentPhotoIndex.value = newIndex;
    } else if (currentPhotoIndex.value > oldIndex && currentPhotoIndex.value <= newIndex) {
      currentPhotoIndex.value = currentPhotoIndex.value - 1;
    } else if (currentPhotoIndex.value < oldIndex && currentPhotoIndex.value >= newIndex) {
      currentPhotoIndex.value = currentPhotoIndex.value + 1;
    }
    photos.refresh();
    triggerAnimationUpdate();
    _saveHistory();
  }

  void onAddDanmakuTap() {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    danmakus.add(AlbumDanmakuEntity(
      albumId: 0,
      content: 'New Danmaku',
      timePoint: 0.0,
      createdAt: now,
    ));
    danmakus.refresh();
    _startDanmakuAnimation();
  }

  void onDeleteDanmakuTap(int index) {
    if (index >= 0 && index < danmakus.length) {
      danmakus.removeAt(index);
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
                  },
                ),
                SizedBox(height: 16.h),
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Time Point (seconds)',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: danmaku.timePoint.toString()),
                  onChanged: (value) {
                    final timePoint = double.tryParse(value) ?? 0.0;
                    danmakus[index] = AlbumDanmakuEntity(
                      id: danmaku.id,
                      albumId: danmaku.albumId,
                      content: danmaku.content,
                      timePoint: timePoint,
                      style: danmaku.style,
                      createdAt: danmaku.createdAt,
                    );
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    SizedBox(width: 8.w),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Save', style: TextStyle(color: accentColor)),
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

  void onTitleEditTap() {
    final textController = TextEditingController(text: albumTitle.value);
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0B0B1E),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Title', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Album Title',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                controller: textController,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () {
                      albumTitle.value = textController.text.isEmpty ? 'Untitled Album' : textController.text;
                      Get.back();
                    },
                    child: Text('Save', style: TextStyle(color: accentColor)),
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

