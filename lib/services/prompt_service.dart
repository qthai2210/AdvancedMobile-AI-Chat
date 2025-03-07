import 'package:aichatbot/models/prompt_model.dart';

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
    if (_prompts.isEmpty) {
      // In a real app, load from API or storage
      await _loadInitialPrompts();
    }
    return _prompts;
  }

  // Get private prompts for the current user
  static Future<List<Prompt>> getPrivatePrompts() async {
    if (_privatePrompts.isEmpty) {
      // In a real app, load from API or storage
      await _loadInitialPrivatePrompts();
    }
    return _privatePrompts.where((p) => p.ownerId == _currentUserId).toList();
  }

  // Get only favorite prompts
  static Future<List<Prompt>> getFavoritePrompts() async {
    final publicPrompts = await getPrompts();
    final privatePrompts = await getPrivatePrompts();

    // Combine public and private favorites
    return [
      ...publicPrompts,
      ...privatePrompts,
    ].where((p) => _favorites.contains(p.id)).toList();
  }

  // Add or remove a prompt from favorites
  static Future<bool> toggleFavorite(String promptId) async {
    if (_favorites.contains(promptId)) {
      _favorites.remove(promptId);
      // In a real app, save changes to storage
      return false; // Not a favorite anymore
    } else {
      _favorites.add(promptId);
      // In a real app, save changes to storage
      return true; // Now a favorite
    }
  }

  // Check if a prompt is a favorite
  static bool isFavorite(String promptId) {
    return _favorites.contains(promptId);
  }

  // Get prompts filtered by category (can be public, private or both)
  static Future<List<Prompt>> getPromptsByCategory(
    String category, {
    bool includePublic = true,
    bool includePrivate = true,
  }) async {
    List<Prompt> result = [];

    if (includePublic) {
      final publicPrompts = await getPrompts();
      if (category.toLowerCase() != 'all') {
        result.addAll(
          publicPrompts.where(
            (p) => p.categories.any(
              (c) => c.toLowerCase() == category.toLowerCase(),
            ),
          ),
        );
      } else {
        result.addAll(publicPrompts);
      }
    }

    if (includePrivate) {
      final privatePrompts = await getPrivatePrompts();
      if (category.toLowerCase() != 'all') {
        result.addAll(
          privatePrompts.where(
            (p) => p.categories.any(
              (c) => c.toLowerCase() == category.toLowerCase(),
            ),
          ),
        );
      } else {
        result.addAll(privatePrompts);
      }
    }

    return result;
  }

  // Create a new private prompt
  static Future<Prompt> createPrivatePrompt(
    String title,
    String content,
    String description,
    List<String> categories,
  ) async {
    // In a real app, this would save to a database
    await Future.delayed(const Duration(milliseconds: 300));

    final newPrompt = Prompt(
      id: 'private_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      description: description,
      categories: categories,
      createdAt: DateTime.now(),
      isPrivate: true,
      ownerId: _currentUserId,
      authorName: "Me", // For private prompts, author is the current user
    );

    _privatePrompts.add(newPrompt);
    return newPrompt;
  }

  // Save a public prompt as private (copy to private collection)
  static Future<Prompt> saveAsPrivate(Prompt publicPrompt) async {
    final privateVersion = publicPrompt.copyWith(
      id: 'private_${DateTime.now().millisecondsSinceEpoch}',
      isPrivate: true,
      ownerId: _currentUserId,
    );

    _privatePrompts.add(privateVersion);
    return privateVersion;
  }

  // Update a private prompt
  static Future<bool> updatePrivatePrompt(Prompt prompt) async {
    if (!prompt.isPrivate || prompt.ownerId != _currentUserId) {
      return false; // Can only update own private prompts
    }

    final index = _privatePrompts.indexWhere((p) => p.id == prompt.id);
    if (index >= 0) {
      _privatePrompts[index] = prompt;
      return true;
    }
    return false;
  }

  // Delete a private prompt
  static Future<bool> deletePrivatePrompt(String promptId) async {
    final index = _privatePrompts.indexWhere(
      (p) => p.id == promptId && p.ownerId == _currentUserId,
    );

    if (index >= 0) {
      _privatePrompts.removeAt(index);
      return true;
    }
    return false;
  }

  // Load initial mock public prompts data
  static Future<void> _loadInitialPrompts() async {
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
        categories: ['Marketing', 'Writing', 'Business'],
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
        categories: ['Coding', 'Education'],
        useCount: 843,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        authorName: 'Dev Helper',
      ),
      // Add more sample public prompts as needed
    ]);
  }

  // Load initial mock private prompts data
  static Future<void> _loadInitialPrivatePrompts() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data for private prompts
    _privatePrompts.addAll([
      Prompt(
        id: 'private_1',
        title: 'My Custom Email Template',
        content:
            'Dear [name], I hope this email finds you well. I wanted to reach out about [topic]...',
        description: 'Personal email template for business inquiries',
        categories: ['Writing', 'Business'],
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
        categories: ['Business', 'Personal'],
        useCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        authorName: 'Me',
        isPrivate: true,
        ownerId: _currentUserId,
      ),
    ]);
  }
}
