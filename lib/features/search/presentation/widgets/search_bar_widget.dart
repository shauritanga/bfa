import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = 'Search products',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20.w,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),

          // Clear button
          if (widget.controller.text.isNotEmpty)
            IconButton(
              onPressed: widget.onClear,
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 18.w,
              ),
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
            )
          else
            SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
