import 'package:get/get.dart';
import '../db_album/data.dart';

class TagSuggestionService extends GetxService {
  final db = Get.find<AlbumDB>();

  static const List<String> commonTags = [
    'travel',
    'food',
    'pet',
    'sport',
    'nature',
    'family',
    'friends',
    'party',
    'wedding',
    'birthday',
    'vacation',
    'sunset',
    'beach',
    'mountain',
    'city',
    'art',
    'music',
    'love',
    'fun',
    'memories',
  ];

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) {
      final frequentTags = await getFrequentTags();
      return [...frequentTags, ...commonTags].take(10).toList();
    }

    final lowerQuery = query.toLowerCase();
    final suggestions = <String>[];

    final frequentTags = await getFrequentTags();
    for (var tag in frequentTags) {
      if (tag.toLowerCase().contains(lowerQuery) && !suggestions.contains(tag)) {
        suggestions.add(tag);
      }
    }

    for (var tag in commonTags) {
      if (tag.toLowerCase().contains(lowerQuery) && !suggestions.contains(tag)) {
        suggestions.add(tag);
      }
    }

    return suggestions.take(10).toList();
  }

  Future<List<String>> getFrequentTags() async {
    try {
      final albums = await db.getAlbums();
      final tagCounts = <String, int>{};

      for (var album in albums) {
        if (album.tags != null && album.tags!.isNotEmpty) {
          final tags = album.tags!.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
          for (var tag in tags) {
            tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
          }
        }
      }

      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTags.take(10).map((e) => e.key).toList();
    } catch (e) {
      return [];
    }
  }

  List<String> parseTags(String tagString) {
    if (tagString.isEmpty) return [];
    return tagString.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  String formatTags(List<String> tags) {
    return tags.join(',');
  }

  bool hasDuplicate(String newTag, String existingTags) {
    final tags = parseTags(existingTags);
    return tags.any((t) => t.toLowerCase() == newTag.toLowerCase());
  }

  String addTag(String newTag, String existingTags) {
    if (hasDuplicate(newTag, existingTags)) {
      return existingTags;
    }
    final tags = parseTags(existingTags);
    tags.add(newTag.trim());
    return formatTags(tags);
  }
}

