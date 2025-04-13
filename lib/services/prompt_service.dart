import 'package:aichatbot/models/prompt_model.dart';
import 'package:flutter/foundation.dart';

class PromptService {
  // In-memory cache of prompts
  static final List<Prompt> _prompts = []; // Public prompts
  static final List<Prompt> _privatePrompts = []; // Private prompts

  // In-memory set of favorite prompt IDs
  static final Set<String> _favorites = {};

  // Mock current user ID
  static const String _currentUserId = "current_user_123";

  // Get all public prompts, loading if necessary
  static Future<List<Prompt>> getPrompts() async {
    debugPrint('PromptService: Getting all public prompts');

    if (_prompts.isEmpty) {
      debugPrint(
          'PromptService: Public prompts cache empty, loading initial data');
      // In a real app, load from API or storage
      await _loadInitialPrompts();
    }

    debugPrint('PromptService: Returning ${_prompts.length} public prompts');
    return _prompts;
  }

  // Get private prompts for the current user
  static Future<List<Prompt>> getPrivatePrompts() async {
    debugPrint(
        'PromptService: Getting private prompts for user $_currentUserId');

    if (_privatePrompts.isEmpty) {
      debugPrint(
          'PromptService: Private prompts cache empty, loading initial data');
      // In a real app, load from API or storage
      await _loadInitialPrivatePrompts();
    }

    final userPrompts =
        _privatePrompts.where((p) => p.ownerId == _currentUserId).toList();
    debugPrint(
        'PromptService: Returning ${userPrompts.length} private prompts');
    return userPrompts;
  }

  // Get only favorite prompts
  static Future<List<Prompt>> getFavoritePrompts() async {
    debugPrint('PromptService: Getting favorite prompts');

    final publicPrompts = await getPrompts();
    final privatePrompts = await getPrivatePrompts();

    // Combine public and private favorites
    final favorites = [
      ...publicPrompts,
      ...privatePrompts,
    ].where((p) => _favorites.contains(p.id)).toList();

    debugPrint('PromptService: Returning ${favorites.length} favorite prompts');
    return favorites;
  }

  // Add or remove a prompt from favorites
  static Future<bool> toggleFavorite(String promptId) async {
    debugPrint('PromptService: Toggling favorite status for prompt $promptId');

    if (_favorites.contains(promptId)) {
      _favorites.remove(promptId);
      debugPrint('PromptService: Removed prompt $promptId from favorites');
      // In a real app, save changes to storage
      return false; // Not a favorite anymore
    } else {
      _favorites.add(promptId);
      debugPrint('PromptService: Added prompt $promptId to favorites');
      // In a real app, save changes to storage
      return true; // Now a favorite
    }
  }

  // Check if a prompt is a favorite
  static bool isFavorite(String promptId) {
    final isFav = _favorites.contains(promptId);
    debugPrint(
        'PromptService: Checking if prompt $promptId is favorite: $isFav');
    return isFav;
  }

  // Get prompts filtered by category (can be public, private or both)
  static Future<List<Prompt>> getPromptsByCategory(
    String category, {
    bool includePublic = true,
    bool includePrivate = true,
  }) async {
    debugPrint(
        'PromptService: Getting prompts by category: $category (public: $includePublic, private: $includePrivate)');

    List<Prompt> result = [];

    if (includePublic) {
      final publicPrompts = await getPrompts();
      if (category.toLowerCase() != 'all') {
        final filtered = publicPrompts
            .where(
              (p) => p.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();

        debugPrint(
            'PromptService: Found ${filtered.length} public prompts in category $category');
        result.addAll(filtered);
      } else {
        debugPrint(
            'PromptService: Adding all ${publicPrompts.length} public prompts (all categories)');
        result.addAll(publicPrompts);
      }
    }

    if (includePrivate) {
      final privatePrompts = await getPrivatePrompts();
      if (category.toLowerCase() != 'all') {
        final filtered = privatePrompts
            .where(
              (p) => p.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();

        debugPrint(
            'PromptService: Found ${filtered.length} private prompts in category $category');
        result.addAll(filtered);
      } else {
        debugPrint(
            'PromptService: Adding all ${privatePrompts.length} private prompts (all categories)');
        result.addAll(privatePrompts);
      }
    }

    debugPrint(
        'PromptService: Returning ${result.length} total prompts for category $category');
    return result;
  }

  // Create a new private prompt
  static Future<Prompt> createPrivatePrompt(
    String title,
    String content,
    String description,
    String category,
  ) async {
    debugPrint(
        'PromptService: Creating new private prompt with title: "$title", category: $category');

    // In a real app, this would save to a database
    await Future.delayed(const Duration(milliseconds: 300));

    final newPrompt = Prompt(
      id: 'private_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      isPrivate: true,
      ownerId: _currentUserId,
      authorName: "Me", // For private prompts, author is the current user
    );

    _privatePrompts.add(newPrompt);
    debugPrint(
        'PromptService: Created new private prompt with ID: ${newPrompt.id}');
    return newPrompt;
  }

  // Save a public prompt as private (copy to private collection)
  static Future<Prompt> saveAsPrivate(Prompt publicPrompt) async {
    debugPrint(
        'PromptService: Saving public prompt ${publicPrompt.id} as private');

    final privateVersion = publicPrompt.copyWith(
      id: 'private_${DateTime.now().millisecondsSinceEpoch}',
      isPrivate: true,
      ownerId: _currentUserId,
    );

    _privatePrompts.add(privateVersion);
    debugPrint(
        'PromptService: Created private copy with new ID: ${privateVersion.id}');
    return privateVersion;
  }

  // Update a private prompt
  static Future<bool> updatePrivatePrompt(Prompt prompt) async {
    debugPrint(
        'PromptService: Attempting to update private prompt ${prompt.id}');

    if (!prompt.isPrivate || prompt.ownerId != _currentUserId) {
      debugPrint(
          'PromptService: Update failed - prompt is not private or user is not the owner');
      return false; // Can only update own private prompts
    }

    final index = _privatePrompts.indexWhere((p) => p.id == prompt.id);
    if (index >= 0) {
      _privatePrompts[index] = prompt;
      debugPrint('PromptService: Successfully updated prompt ${prompt.id}');
      return true;
    }

    debugPrint('PromptService: Update failed - prompt ${prompt.id} not found');
    return false;
  }

  // Delete a private prompt
  static Future<bool> deletePrivatePrompt(String promptId) async {
    debugPrint('PromptService: Attempting to delete private prompt $promptId');

    final index = _privatePrompts.indexWhere(
      (p) => p.id == promptId && p.ownerId == _currentUserId,
    );

    if (index >= 0) {
      _privatePrompts.removeAt(index);
      debugPrint('PromptService: Successfully deleted prompt $promptId');
      return true;
    }

    debugPrint(
        'PromptService: Delete failed - prompt $promptId not found or user is not the owner');
    return false;
  }

  // Increment a prompt's use count
  static Future<void> incrementPromptUseCount(String promptId) async {
    debugPrint('PromptService: Incrementing use count for prompt $promptId');

    // Find in public prompts
    final publicIndex = _prompts.indexWhere((p) => p.id == promptId);
    if (publicIndex >= 0) {
      final oldCount = _prompts[publicIndex].useCount;
      _prompts[publicIndex] = _prompts[publicIndex].copyWith(
        useCount: oldCount + 1,
      );
      debugPrint(
          'PromptService: Incremented public prompt use count: $oldCount → ${oldCount + 1}');
    }

    // Find in private prompts
    final privateIndex = _privatePrompts.indexWhere((p) => p.id == promptId);
    if (privateIndex >= 0) {
      final oldCount = _privatePrompts[privateIndex].useCount;
      _privatePrompts[privateIndex] = _privatePrompts[privateIndex].copyWith(
        useCount: oldCount + 1,
      );
      debugPrint(
          'PromptService: Incremented private prompt use count: $oldCount → ${oldCount + 1}');
    }

    // In a real app, you would update the database
    if (publicIndex < 0 && privateIndex < 0) {
      debugPrint(
          'PromptService: Warning - prompt $promptId not found for incrementing use count');
    }
  }

  // Load initial mock public prompts data
  static Future<void> _loadInitialPrompts() async {
    debugPrint('PromptService: Loading initial public prompts data');

    // This would be a network request or database read in a real app
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data for public prompts
    _prompts.addAll([
      Prompt(
        id: '1',
        title: 'Email Marketing Campaign',
        content:
            'Write a compelling email marketing campaign for [product] targeting [audience].',
        description:
            'Create effective email marketing campaigns that increase engagement and conversions.',
        category: 'marketing',
        useCount: 1250,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        authorName: 'Marketing Pro',
      ),
      Prompt(
        id: '2',
        title: 'Code Refactoring Helper',
        content:
            'Refactor this code to improve [specific aspect]: ```[code]```',
        description:
            'Get suggestions for improving your code quality, readability, and performance.',
        category: 'coding',
        useCount: 843,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        authorName: 'Dev Helper',
      ),
      // Add more sample public prompts as needed
    ]);

    debugPrint(
        'PromptService: Loaded ${_prompts.length} initial public prompts');
  }

  // Load initial mock private prompts data
  static Future<void> _loadInitialPrivatePrompts() async {
    debugPrint('PromptService: Loading initial private prompts data');

    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data for private prompts
    _privatePrompts.addAll([
      Prompt(
        id: 'private_1',
        title: 'My Custom Email Template',
        content:
            'Dear [name], I hope this email finds you well. I wanted to reach out about [topic]...',
        description: 'Personal email template for business inquiries',
        category: 'writing',
        useCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        authorName: 'Me',
        isPrivate: true,
        ownerId: _currentUserId,
      ),
      Prompt(
        id: 'private_2',
        title: 'Project Status Update',
        content:
            'Project: [project_name]\nStatus: [status]\nKey Achievements: [achievements]\nChallenges: [challenges]\nNext Steps: [next_steps]',
        description: 'Template for weekly project status updates',
        category: 'business',
        useCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        authorName: 'Me',
        isPrivate: true,
        ownerId: _currentUserId,
      ),
    ]);

    debugPrint(
        'PromptService: Loaded ${_privatePrompts.length} initial private prompts');
  }
}
