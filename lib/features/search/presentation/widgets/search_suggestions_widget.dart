import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final String query;
  final List<String> suggestions;
  final List<String> history;
  final Function(String) onSuggestionTap;

  const SearchSuggestionsWidget({
    super.key,
    required this.query,
    required this.suggestions,
    required this.history,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Search suggestions from history
          if (suggestions.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Recent searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ...suggestions.map((suggestion) => _buildSuggestionItem(
              context,
              suggestion,
              Icons.history,
              onSuggestionTap,
            )),
          ],

          // Popular searches that match query
          if (query.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 8.w),
              child: Text(
                'Popular searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ..._getPopularSuggestions(query).map((suggestion) => _buildSuggestionItem(
              context,
              suggestion,
              Icons.trending_up,
              onSuggestionTap,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String suggestion,
    IconData icon,
    Function(String) onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap(suggestion),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20.w,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: _buildHighlightedText(suggestion, query, theme),
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String query, ThemeData theme) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ));
      
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    return spans;
  }

  List<String> _getPopularSuggestions(String query) {
    // Mock popular suggestions - in real app this would come from API
    final popularSearches = [
      'rice basmati',
      'rice jasmine',
      'rice brown',
      'rice white',
      'rice organic',
      'rice flour',
      'banana green',
      'banana ripe',
      'tomato red',
      'tomato green',
    ];

    return popularSearches
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }
}
