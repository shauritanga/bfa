import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';

class ProductSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String hintText;
  final bool enabled;

  const ProductSearchBar({
    super.key,
    this.initialQuery,
    required this.onSearch,
    this.onClear,
    this.hintText = 'Search products...',
    this.enabled = true,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _hasText = widget.initialQuery?.isNotEmpty ?? false;

    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.onSearch(value.trim());
      _focusNode.unfocus();
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: _focusNode.hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20.w,
            ),
          ),

          // Text Field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _onSubmitted,
              onChanged: (value) {
                // Optional: Implement real-time search with debouncing
                // For now, we'll only search on submit
              },
            ),
          ),

          // Clear/Voice Button
          if (_hasText)
            IconButton(
              onPressed: _onClear,
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20.w,
              ),
              constraints: BoxConstraints(
                minWidth: 40.w,
                minHeight: 40.h,
              ),
            )
          else
            IconButton(
              onPressed: () {
                // TODO: Implement voice search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice search coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                Icons.mic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20.w,
              ),
              constraints: BoxConstraints(
                minWidth: 40.w,
                minHeight: 40.h,
              ),
            ),

          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

/// Search suggestions widget for autocomplete
class ProductSearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final VoidCallback? onClearHistory;

  const ProductSearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Recent Searches',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onClearHistory != null)
                  TextButton(
                    onPressed: onClearHistory,
                    child: Text(
                      'Clear',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Suggestions List
          ...suggestions.map((suggestion) => ListTile(
                leading: Icon(
                  Icons.history,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20.w,
                ),
                title: Text(
                  suggestion,
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Icon(
                  Icons.north_west,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 16.w,
                ),
                onTap: () => onSuggestionTap(suggestion),
                dense: true,
              )),
        ],
      ),
    );
  }
}

/// Popular searches widget
class PopularSearches extends StatelessWidget {
  final List<String> popularSearches;
  final Function(String) onSearchTap;

  const PopularSearches({
    super.key,
    required this.popularSearches,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (popularSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Popular Searches',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: popularSearches.map((search) => ActionChip(
              label: Text(search),
              onPressed: () => onSearchTap(search),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
            )).toList(),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
