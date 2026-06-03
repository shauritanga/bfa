import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/trending_products_widget.dart';
import '../widgets/search_suggestions_widget.dart';
import '../widgets/search_results_widget.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../../core/router/app_routes.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _currentQuery = '';
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchFocusNode = FocusNode();
    _currentQuery = widget.initialQuery ?? '';

    // If there's an initial query, perform search
    if (widget.initialQuery?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _searchFocusNode.hasFocus && _currentQuery.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query;
      _showSuggestions = query.isNotEmpty && _searchFocusNode.hasFocus;
    });

    // Update suggestions
    ref.read(searchHistoryProvider.notifier).updateSuggestions(query);
  }

  void _performSearch(String query) {
    print('🔍 SearchPage: _performSearch called with query: "$query"');

    if (query.trim().isEmpty) {
      print('🔍 SearchPage: Empty query, returning');
      return;
    }

    print('🔍 SearchPage: Adding to search history and performing search');

    // Add to search history
    ref.read(searchHistoryProvider.notifier).addToHistory(query);

    // Perform search
    ref.read(productProvider.notifier).searchProducts(query);

    // Hide suggestions and unfocus
    setState(() {
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();

    print('🔍 SearchPage: Search initiated');
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _showSuggestions = false;
    });
    ref.read(productProvider.notifier).searchProducts('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productProvider);
    final searchHistoryState = ref.watch(searchHistoryProvider);
    final trendingSearches = ref.watch(trendingSearchesProvider);

    final hasSearchResults =
        _currentQuery.isNotEmpty && productState.searchResults.isNotEmpty;
    final hasSearchQuery = _currentQuery.isNotEmpty;
    final isSearching = productState.isLoading && hasSearchQuery;

    // Debug logging
    print('🔍 SearchPage: Build - currentQuery: "$_currentQuery"');
    print('🔍 SearchPage: Build - hasSearchQuery: $hasSearchQuery');
    print('🔍 SearchPage: Build - isSearching: $isSearching');
    print('🔍 SearchPage: Build - hasSearchResults: $hasSearchResults');
    print(
      '🔍 SearchPage: Build - searchResults count: ${productState.searchResults.length}',
    );
    print('🔍 SearchPage: Build - productState.error: ${productState.error}');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // If there's nothing to pop, navigate to home
              context.goNamed(AppRoute.home.name);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          onSubmitted: _performSearch,
          onClear: _clearSearch,
        ),
      ),
      body: Stack(
        children: [
          // Main content
          if (!_showSuggestions) ...[
            if (!hasSearchQuery)
              // Initial state - trending products
              TrendingProductsWidget(
                trendingSearches: trendingSearches,
                searchHistory: searchHistoryState.history,
                onSearchTap: _onSuggestionTap,
                onHistoryTap: _onSuggestionTap,
                onClearHistory: () {
                  ref.read(searchHistoryProvider.notifier).clearHistory();
                },
              )
            else if (isSearching)
              // Loading state
              const Center(child: CircularProgressIndicator())
            else if (hasSearchResults)
              // Search results
              SearchResultsWidget(
                query: _currentQuery,
                results: productState.searchResults,
                onProductTap: (product) {
                  context.goNamed(
                    AppRoute.productDetails.name,
                    pathParameters: {'id': product.id},
                  );
                },
              )
            else if (productState.error != null && hasSearchQuery)
              // Error state
              _buildErrorState(theme, productState.error!)
            else if (hasSearchQuery)
              // No results
              _buildNoResults(theme),
          ],

          // Search suggestions overlay
          if (_showSuggestions)
            SearchSuggestionsWidget(
              query: _currentQuery,
              suggestions: searchHistoryState.suggestions,
              history: searchHistoryState.history,
              onSuggestionTap: _onSuggestionTap,
            ),
        ],
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80.w,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No results for "$_currentQuery"',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching for something else',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.w, color: theme.colorScheme.error),
          SizedBox(height: 16.h),
          Text(
            'Search Error',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              _performSearch(_currentQuery);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
