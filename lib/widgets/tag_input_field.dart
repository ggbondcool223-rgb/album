import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../services/tag_suggestion_service.dart';
import '../main.dart';

class TagInputField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLength;

  const TagInputField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.maxLength = 10,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  late TextEditingController _controller;
  final TagSuggestionService _tagService = Get.find<TagSuggestionService>();
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _loadSuggestions('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions(String query) async {
    final suggestions = await _tagService.getSuggestions(query);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = query.isEmpty || suggestions.isNotEmpty;
        _currentQuery = query;
      });
    }
  }

  void _onTextChanged(String value) {
    widget.onChanged(value);
    final tags = _tagService.parseTags(value);
    if (tags.isNotEmpty) {
      final lastTag = tags.last;
      _loadSuggestions(lastTag);
    } else {
      _loadSuggestions('');
    }
  }

  void _onSuggestionTap(String suggestion) {
    final currentTags = _tagService.parseTags(_controller.text);
    if (currentTags.isNotEmpty) {
      currentTags.removeLast();
    }
    
    if (!_tagService.hasDuplicate(suggestion, _tagService.formatTags(currentTags))) {
      currentTags.add(suggestion);
    }
    
    final newValue = _tagService.formatTags(currentTags);
    _controller.text = newValue;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newValue.length),
    );
    widget.onChanged(newValue);
    _loadSuggestions('');
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: TextField(
            maxLength: widget.maxLength,
            controller: _controller,
            onChanged: _onTextChanged,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Enter tags (comma separated)',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
              border: InputBorder.none,
              counterText: '',
            ),
            onTap: () {
              setState(() {
                _showSuggestions = true;
              });
            },
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  onTap: () => _onSuggestionTap(suggestion),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}

