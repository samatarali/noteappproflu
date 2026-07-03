import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum NoteCategory { all, personal, work, study, ideas, other }

extension NoteCategoryExtension on NoteCategory {
  String get name {
    switch (this) {
      case NoteCategory.all: return 'All Notes';
      case NoteCategory.personal: return 'Personal';
      case NoteCategory.work: return 'Work';
      case NoteCategory.study: return 'Study';
      case NoteCategory.ideas: return 'Ideas';
      case NoteCategory.other: return 'Other';
    }
  }

  String get value {
    switch (this) {
      case NoteCategory.all: return 'all';
      case NoteCategory.personal: return 'personal';
      case NoteCategory.work: return 'work';
      case NoteCategory.study: return 'study';
      case NoteCategory.ideas: return 'ideas';
      case NoteCategory.other: return 'other';
    }
  }

  Color get color {
    switch (this) {
      case NoteCategory.all: return AppColors.primary;
      case NoteCategory.personal: return AppColors.personal;
      case NoteCategory.work: return AppColors.work;
      case NoteCategory.study: return AppColors.study;
      case NoteCategory.ideas: return AppColors.ideas;
      case NoteCategory.other: return AppColors.other;
    }
  }

  IconData get icon {
    switch (this) {
      case NoteCategory.all: return Icons.notes_rounded;
      case NoteCategory.personal: return Icons.person_rounded;
      case NoteCategory.work: return Icons.work_rounded;
      case NoteCategory.study: return Icons.school_rounded;
      case NoteCategory.ideas: return Icons.lightbulb_rounded;
      case NoteCategory.other: return Icons.more_horiz_rounded;
    }
  }

  static NoteCategory fromString(String value) {
    switch (value) {
      case 'personal': return NoteCategory.personal;
      case 'work': return NoteCategory.work;
      case 'study': return NoteCategory.study;
      case 'ideas': return NoteCategory.ideas;
      case 'other': return NoteCategory.other;
      default: return NoteCategory.personal;
    }
  }
}

class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final NoteCategory category;
  final bool isPinned;
  final bool isFavorite;
  final bool isDraft;
  final bool isTrashed;
  final bool isArchived;
  final List<String> tags;
  final String? color;
  final DateTime? reminderAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.isPinned = false,
    this.isFavorite = false,
    this.isDraft = false,
    this.isTrashed = false,
    this.isArchived = false,
    this.tags = const [],
    this.color,
    this.reminderAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: NoteCategoryExtension.fromString(json['category'] ?? 'personal'),
      // 🛡️ XALKA: Waxaa halkan loogu parse-gariyey si ammaan ah si bool error loo waayo
      isPinned: _parseBool(json['is_pinned']),
      isFavorite: _parseBool(json['is_favorite']),
      isDraft: _parseBool(json['is_draft']),
      isTrashed: _parseBool(json['is_trashed']),
      isArchived: _parseBool(json['is_archived']),
      tags: List<String>.from(json['tags'] ?? []),
      color: json['color'],
      reminderAt: json['reminder_at'] != null
          ? DateTime.parse(json['reminder_at'])
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category.value,
      'is_pinned': isPinned,
      'is_favorite': isFavorite,
      'is_draft': isDraft,
      'is_trashed': isTrashed,
      'is_archived': isArchived,
      'tags': tags,
      'color': color,
      'reminder_at': reminderAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    bool? isPinned,
    bool? isFavorite,
    bool? isDraft,
    bool? isTrashed,
    bool? isArchived,
    List<String>? tags,
    String? color,
    DateTime? reminderAt,
  }) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isDraft: isDraft ?? this.isDraft,
      isTrashed: isTrashed ?? this.isTrashed,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      reminderAt: reminderAt ?? this.reminderAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // 🛡️ HELPER FUNCTION: Ka hortagga nooc kasta oo Bool Type Error ah
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1; // Haddii Supabase u soo diro 1 ama 0
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}