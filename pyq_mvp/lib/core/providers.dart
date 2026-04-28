import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';
import '../models/branch.dart';
import '../models/year.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/question.dart';
import '../models/pyq_source.dart';
import '../models/image_item.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());
final aiServiceProvider = Provider((ref) => AiService());

// Theme Mode Provider using the modern Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final branchesProvider = FutureProvider<List<Branch>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getBranches();
});

final yearsProvider = FutureProvider<List<Year>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getYears();
});

final subjectsProvider = FutureProvider.family<List<Subject>, ({String branchId, String yearId})>((ref, arg) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getSubjects(branchId: arg.branchId, yearId: arg.yearId);
});

final topicsProvider = FutureProvider.family<List<Topic>, String>((ref, subjectId) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getTopics(subjectId);
});

final questionsProvider = FutureProvider.family<List<Question>, String>((ref, topicId) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getQuestionsByTopic(topicId);
});

final questionDetailProvider = FutureProvider.family<Question, String>((ref, questionId) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getQuestionDetail(questionId);
});

final pyqSourcesProvider = FutureProvider.family<List<PyqSource>, String>((ref, questionId) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getPyqSourcesForQuestion(questionId);
});

final imagesProvider = FutureProvider.family<List<ImageItem>, String>((ref, questionId) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getImagesForQuestion(questionId);
});

// PDF Loading State Provider
class PdfLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

final pdfLoadingProvider = NotifierProvider<PdfLoadingNotifier, bool>(PdfLoadingNotifier.new);
