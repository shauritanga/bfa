import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Search history state
class SearchHistoryState {
  final List<String> history;
  final List<String> suggestions;
  final bool isLoading;

  const SearchHistoryState({
    this.history = const [],
    this.suggestions = const [],
    this.isLoading = false,
  });

  SearchHistoryState copyWith({
    List<String>? history,
    List<String>? suggestions,
    bool? isLoading,
  }) {
    return SearchHistoryState(
      history: history ?? this.history,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Search history notifier
class SearchHistoryNotifier extends StateNotifier<SearchHistoryState> {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;

  SearchHistoryNotifier() : super(const SearchHistoryState()) {
    _loadHistory();
  }

  /// Load search history from local storage
  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      state = state.copyWith(
        history: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Add search query to history
  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();
    final currentHistory = List<String>.from(state.history);

    // Remove if already exists
    currentHistory.remove(trimmedQuery);
    
    // Add to beginning
    currentHistory.insert(0, trimmedQuery);
    
    // Limit to max items
    if (currentHistory.length > _maxHistoryItems) {
      currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
    }

    state = state.copyWith(history: currentHistory);

    // Save to local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, currentHistory);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Remove item from history
  Future<void> removeFromHistory(String query) async {
    final currentHistory = List<String>.from(state.history);
    currentHistory.remove(query);
    state = state.copyWith(history: currentHistory);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, currentHistory);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    state = state.copyWith(history: []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Update suggestions based on query
  void updateSuggestions(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }

    final filteredHistory = state.history
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();

    state = state.copyWith(suggestions: filteredHistory);
  }
}

/// Search history provider
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, SearchHistoryState>((ref) {
  return SearchHistoryNotifier();
});

/// Trending searches (mock data - in real app this would come from API)
final trendingSearchesProvider = Provider<List<String>>((ref) {
  return [
    'rice',
    'rice basmati',
    'rice jasmine',
    'rice brown',
    'rice white',
    'rice organic',
    'rice flour',
    'rice vinegar',
    'banana green',
    'tomato paper',
  ];
});

/// Popular products (mock data - in real app this would come from API)
final popularProductsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'name': 'Product 1', 'image': 'assets/images/product1.jpg'},
    {'name': 'Product 2', 'image': 'assets/images/product2.jpg'},
    {'name': 'Product 3', 'image': 'assets/images/product3.jpg'},
    {'name': 'Product 4', 'image': 'assets/images/product4.jpg'},
  ];
});
