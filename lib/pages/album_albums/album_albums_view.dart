import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:typed_data';
import '../../main.dart';
import 'album_albums_logic.dart';
import '../../db_album/album_entity.dart';

class AlbumAlbumsView extends GetView<AlbumAlbumsLogic> {
  const AlbumAlbumsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Albums'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AlbumSearchDelegate(controller),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: accentColor));
        }

        return RefreshIndicator(
            onRefresh: controller.loadAlbums,
            color: accentColor,
            child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildAlbumsList()));
      }),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null, controller.selectedType.value == null),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Music', 'music', controller.selectedType.value == 'music'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Text & Image', 'text_image', controller.selectedType.value == 'text_image'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Video', 'video', controller.selectedType.value == 'video'),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildFilterChip(String label, String? type, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.onTypeFilterChanged(selected ? type : null);
      },
      selectedColor: accentColor.withOpacity(0.3),
      checkmarkColor: accentColor,
      labelStyle: TextStyle(
        color: isSelected ? accentColor : Colors.white,
      ),
    );
  }

  Widget _buildAlbumsList() {
    return Obx(() {
      if (controller.albums.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, color: Colors.grey, size: 64.sp),
                SizedBox(height: 16.h),
                Text(
                  'No albums yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.albums.length,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemBuilder: (context, index) {
          final album = controller.albums[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAlbumCard(album),
          );
        },
      );
    });
  }

  Widget _buildAlbumCard(AlbumEntity album) {
    Color typeColor;
    IconData typeIcon;
    if (album.type == 'music') {
      typeColor = accentColor;
      typeIcon = Icons.music_note;
    } else if (album.type == 'text_image') {
      typeColor = const Color(0xFF00FFC2);
      typeIcon = Icons.photo_library;
    } else {
      typeColor = const Color(0xFFFF00C7);
      typeIcon = Icons.video_library;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.05),
            const Color(0xFFFF00C7).withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.w),
                    topRight: Radius.circular(16.w),
                  ),
                ),
                child: album.coverData != null
                    ? Image.memory(
                        album.coverData!,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.image, color: Colors.grey, size: 48.sp),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Row(
                  children: [
                    _buildIconButton(
                      Icons.more_horiz,
                      () => controller.onMoreVertTap(album),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12.h,
                left: 12.w,
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Row(
                        children: [
                          Icon(typeIcon, color: Colors.white, size: 12.sp),
                          SizedBox(width: 4.w),
                          Text(
                            album.type == 'music'
                                ? 'Music'
                                : album.type == 'text_image'
                                    ? 'Text Image'
                                    : 'Video',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  top: 5,
                  left: 5,
                  child: Visibility(
                    visible: album.tags != null && album.tags!.isNotEmpty,
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: (album.tags?.split(',') ?? []).map((tag) {
                            final trimmedTag = tag.trim();
                            if (trimmedTag.isEmpty) return SizedBox.shrink();
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  color: accentColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                trimmedTag,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.onAlbumTap(album),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                            side: BorderSide.none,
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
                            ),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text('Play', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 16.sp),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class AlbumSearchDelegate extends SearchDelegate<String> {
  final AlbumAlbumsLogic controller;
  String _lastQuery = '';

  AlbumSearchDelegate(this.controller);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            _lastQuery = '';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.onSearchChanged('');
            });
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.onSearchChanged('');
        });
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (_lastQuery != query) {
      _lastQuery = query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.onSearchChanged(query);
      });
    }
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_lastQuery != query) {
      _lastQuery = query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.onSearchChanged(query);
      });
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.albums.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, color: Colors.grey, size: 64.sp),
                SizedBox(height: 16.h),
                Text(
                  'No albums found',
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.albums.length,
        padding: EdgeInsets.all(16.w),
        itemBuilder: (context, index) {
          final album = controller.albums[index];
          return ListTile(
            leading: album.coverData != null
                ? Image.memory(
                    album.coverData!,
                    width: 56.w,
                    height: 56.w,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.image, size: 56.sp),
            title: Text(album.title),
            subtitle: album.tags != null && album.tags!.isNotEmpty
                ? Text(album.tags!)
                : null,
            trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
            onTap: () {
              controller.onAlbumTap(album);
              close(context, album.title);
            },
          );
        },
      );
    });
  }
}
