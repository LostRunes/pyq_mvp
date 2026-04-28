import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/branch.dart';
import '../models/year.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/question.dart';
import '../models/pyq_source.dart';
import '../models/image_item.dart';
import '../models/question_full.dart';
import '../models/topic_with_questions.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Branch>> getBranches() async {
    final res = await supabase.from('branches').select();
    return (res as List).map((e) => Branch.fromJson(e)).toList();
  }

  Future<List<Year>> getYears() async {
    final res = await supabase.from('years').select();
    return (res as List).map((e) => Year.fromJson(e)).toList();
  }

  Future<List<Subject>> getSubjects({required String branchId, required String yearId}) async {
    final res = await supabase
        .from('branch_subjects')
        .select('subjects(id, name, code), semester')
        .eq('branch_id', branchId)
        .eq('year_id', yearId);
    return (res as List)
        .map((e) => Subject.fromJson(e['subjects']))
        .toList();
  }

  Future<List<Topic>> getTopics(String subjectId) async {
    final res = await supabase.from('topics').select().eq('subject_id', subjectId);
    return (res as List).map((e) => Topic.fromJson(e)).toList();
  }

  Future<List<Question>> getQuestionsByTopic(String topicId) async {
    final res = await supabase
        .from('question_topics')
        .select('questions(id, question_text, difficulty)')
        .eq('topic_id', topicId);
    return (res as List)
        .map((e) => Question.fromJson(e['questions']))
        .toList();
  }

  Future<Question> getQuestionDetail(String questionId) async {
    final res = await supabase.from('questions').select().eq('id', questionId).single();
    return Question.fromJson(res);
  }

  Future<List<PyqSource>> getPyqSourcesForQuestion(String questionId) async {
    final res = await supabase
        .from('question_pyq_map')
        .select('pyq_sources(id, year, exam_type, season, question_number)')
        .eq('question_id', questionId);
    return (res as List)
        .map((e) => PyqSource.fromJson(e['pyq_sources']))
        .toList();
  }

  Future<List<ImageItem>> getImagesForQuestion(String questionId) async {
    final res = await supabase
        .from('images')
        .select()
        .eq('question_id', questionId)
        .order('order_index');
    return (res as List).map((e) => ImageItem.fromJson(e)).toList();
  }

  // Optimized Fetch for PDF
  Future<List<QuestionFull>> getQuestionsWithDetails(String topicId) async {
    // 1. Get all questions for the topic
    final questions = await getQuestionsByTopic(topicId);
    
    List<QuestionFull> fullQuestions = [];
    
    // 2. Fetch details for each question (In parallel for speed)
    await Future.wait(questions.map((q) async {
      final pyqs = await getPyqSourcesForQuestion(q.id);
      final images = await getImagesForQuestion(q.id);
      
      fullQuestions.add(QuestionFull(
        text: q.questionText,
        difficulty: q.difficulty,
        imageUrls: images.map((i) => i.imageUrl).toList(),
        pyqMeta: pyqs,
      ));
    }));
    
    return fullQuestions;
  }

  Future<List<TopicWithQuestions>> getFullSubjectData(String subjectId) async {
    final topics = await getTopics(subjectId);
    
    // Parallelize API calls for all topics
    final futures = topics.map((topic) async {
      final questions = await getQuestionsWithDetails(topic.id);
      return TopicWithQuestions(
        topicName: topic.name,
        questions: questions,
      );
    }).toList();

    return await Future.wait(futures);
  }
}
