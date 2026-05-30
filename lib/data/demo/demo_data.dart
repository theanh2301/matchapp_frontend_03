import '../models/chapter_model.dart';
import '../models/daily_challenge_model.dart';
import '../models/dashboard_model.dart';
import '../models/exam_model.dart';
import '../models/flashcard_model.dart';
import '../models/lesson_model.dart';
import '../models/match_card_model.dart';
import '../models/performance_model.dart';
import '../models/practice_list_model.dart';
import '../models/practice_model.dart';
import '../models/profile_model.dart';
import '../models/quiz_model.dart';
import '../models/subject_model.dart';
import '../models/subject_progress_model.dart';
import '../models/suggest_lesson_model.dart';

class DemoData {
  static const bool isOfflineFallback = true;

  static List<SubjectModel> subjects(int gradeId) => [
    SubjectModel(
      subjectId: 1,
      subjectClass: gradeId,
      subjectName: 'Toan hoc',
      totalLessons: 24,
      completedLessons: 9,
      earnedXp: 450,
      totalXp: 1200,
    ),
    SubjectModel(
      subjectId: 2,
      subjectClass: gradeId,
      subjectName: 'Vat ly',
      totalLessons: 18,
      completedLessons: 5,
      earnedXp: 210,
      totalXp: 900,
    ),
    SubjectModel(
      subjectId: 3,
      subjectClass: gradeId,
      subjectName: 'Hoa hoc',
      totalLessons: 16,
      completedLessons: 3,
      earnedXp: 140,
      totalXp: 800,
    ),
  ];

  static List<SubjectProgressModel> subjectProgress() => [
    SubjectProgressModel(
      subjectId: 1,
      subjectName: 'Toan hoc',
      chapterId: 1,
      chapterName: 'Ham so bac hai',
      lessonId: 1,
      lessonName: 'Do thi va dinh parabol',
      completionPercent: 65,
    ),
    SubjectProgressModel(
      subjectId: 1,
      subjectName: 'Toan hoc',
      chapterId: 2,
      chapterName: 'He phuong trinh',
      lessonId: 4,
      lessonName: 'Phuong phap the',
      completionPercent: 40,
    ),
  ];

  static List<DailyChallengeModel> dailyChallenges() => [
    DailyChallengeModel(
      challengeId: 1,
      title: 'Hoan thanh 1 bai hoc',
      description: 'Hoc mot bai ngan de giu nhip moi ngay.',
      xpReward: 50,
      source: 'DEMO',
      targetValue: 1,
      isCompleted: false,
    ),
    DailyChallengeModel(
      challengeId: 2,
      title: 'Lam 5 cau luyen tap',
      description: 'On lai cac cau co ban trong chu de dang hoc.',
      xpReward: 30,
      source: 'DEMO',
      targetValue: 5,
      isCompleted: true,
    ),
  ];

  static List<SuggestedLessonModel> suggestedLessons() => [
    SuggestedLessonModel(
      lessonId: 1,
      lessonName: 'Ham so bac hai',
      isLearned: 1,
    ),
    SuggestedLessonModel(
      lessonId: 2,
      lessonName: 'Dinh va truc doi xung',
      isLearned: 0,
    ),
    SuggestedLessonModel(
      lessonId: 3,
      lessonName: 'Giai phuong trinh bac hai',
      isLearned: 0,
    ),
  ];

  static AllPracticeStatsModel practiceStats() => AllPracticeStatsModel(
    dailyStats: PracticeModel(
      practiceType: 'DAILY',
      totalPractice: 12,
      completedPractice: 5,
    ),
    topicStats: PracticeModel(
      practiceType: 'TOPIC',
      totalPractice: 20,
      completedPractice: 8,
    ),
    challengeStats: PracticeModel(
      practiceType: 'CHALLENGE',
      totalPractice: 8,
      completedPractice: 2,
    ),
  );

  static List<PracticeListModel> practices(String practiceType) => [
    PracticeListModel(
      id: 101,
      title: 'On tap ham so bac hai',
      description: 'Bai demo co the lam thu khi thiet bi dang offline.',
      timeLimit: 15,
      practiceType: practiceType,
      totalQuestions: 5,
      totalXp: 100,
      totalAnswered: 0,
      correctAnswers: 0,
      correctPercent: 0,
    ),
    PracticeListModel(
      id: 102,
      title: 'Phuong trinh va he phuong trinh',
      description: 'Luyen cac buoc bien doi dai so co ban.',
      timeLimit: 20,
      practiceType: practiceType,
      totalQuestions: 8,
      totalXp: 160,
      totalAnswered: 3,
      correctAnswers: 2,
      correctPercent: 67,
    ),
  ];

  static DashboardResponse dashboard(
    int userId,
    DateTime date,
  ) => DashboardResponse(
    stats: UserStatResponse(
      userId: userId,
      totalXP: 450,
      totalLesson: 9,
      totalStudyDay: 6,
      streakDay: 3,
      lastDayStudy: null,
    ),
    weeklyXp: List.generate(7, (index) {
      final day = date.subtract(Duration(days: 6 - index));
      return XpChartResponse(
        date:
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
        totalXp: [20, 55, 35, 80, 60, 90, 110][index],
      );
    }),
  );

  static List<SubjectPerformanceModel> subjectPerformance() => [
    SubjectPerformanceModel(
      subject: 'Toan hoc',
      accuracy: 78,
      weeklyChange: 6,
      level: 'Kha',
    ),
    SubjectPerformanceModel(
      subject: 'Vat ly',
      accuracy: 62,
      weeklyChange: -3,
      level: 'Trung binh',
    ),
  ];

  static List<TypePerformanceModel> typePerformance() => [
    TypePerformanceModel(type: 'Trac nghiem', score: 74),
    TypePerformanceModel(type: 'Ghep the', score: 66),
  ];

  static List<ChapterModel> chapters() => [
    ChapterModel(
      chapterId: 1,
      chapterName: 'Ham so bac hai',
      description: 'Lam quen voi do thi, dinh va truc doi xung.',
      totalLessons: 4,
      completedLessons: 2,
      earnedXp: 120,
      totalPossibleXp: 240,
    ),
    ChapterModel(
      chapterId: 2,
      chapterName: 'Phuong trinh bac hai',
      description: 'Giai phuong trinh bang cong thuc nghiem.',
      totalLessons: 5,
      completedLessons: 1,
      earnedXp: 60,
      totalPossibleXp: 300,
    ),
  ];

  static List<LessonModel> lessons() => [
    LessonModel(
      lessonId: 1,
      lessonName: 'Dinh cua parabol',
      description: 'Xac dinh toa do dinh va truc doi xung.',
      earnedXp: 60,
      totalPossibleXp: 120,
      isFlashcardDone: true,
      isQuestionDone: false,
      isMatchCardDone: false,
    ),
    LessonModel(
      lessonId: 2,
      lessonName: 'Cong thuc nghiem',
      description: 'Ap dung delta de tim nghiem phuong trinh.',
      earnedXp: 0,
      totalPossibleXp: 120,
      isFlashcardDone: false,
      isQuestionDone: false,
      isMatchCardDone: false,
    ),
  ];

  static List<FlashcardModel> flashcards() => [
    FlashcardModel(
      id: 1,
      frontText: 'Cong thuc tinh delta?',
      backText: 'Delta = b^2 - 4ac',
      hint: 'Dung cho ax^2 + bx + c = 0',
      xpReward: 10,
    ),
    FlashcardModel(
      id: 2,
      frontText: 'Toa do x cua dinh parabol?',
      backText: 'x = -b / 2a',
      hint: 'Ap dung cho y = ax^2 + bx + c',
      xpReward: 10,
    ),
  ];

  static List<QuizModel> quizzes() => [
    QuizModel(
      id: 1,
      content: 'Voi y = x^2 - 4x + 3, hoanh do dinh la bao nhieu?',
      typeQuestion: 'QUIZ',
      xpReward: 20,
      answers: [
        AnswerModel(
          id: 1,
          content: '1',
          isCorrect: false,
          description: 'Chua dung.',
        ),
        AnswerModel(
          id: 2,
          content: '2',
          isCorrect: true,
          description: 'x = -b / 2a = 4 / 2 = 2.',
        ),
        AnswerModel(
          id: 3,
          content: '3',
          isCorrect: false,
          description: 'Chua dung.',
        ),
        AnswerModel(
          id: 4,
          content: '4',
          isCorrect: false,
          description: 'Chua dung.',
        ),
      ],
    ),
  ];

  static List<PracticeQuestionModel> practiceQuestions() => [
    PracticeQuestionModel(
      id: 1,
      content: 'Giai phuong trinh x^2 - 5x + 6 = 0',
      xpReward: 20,
      difficulty: 'EASY',
      answers: [
        PracticeAnswerModel(
          id: 1,
          content: 'x = 1, x = 6',
          isCorrect: false,
          description: 'Chua dung.',
        ),
        PracticeAnswerModel(
          id: 2,
          content: 'x = 2, x = 3',
          isCorrect: true,
          description: 'Vi x^2 - 5x + 6 = (x - 2)(x - 3).',
        ),
        PracticeAnswerModel(
          id: 3,
          content: 'x = -2, x = -3',
          isCorrect: false,
          description: 'Chua dung dau.',
        ),
        PracticeAnswerModel(
          id: 4,
          content: 'Vo nghiem',
          isCorrect: false,
          description: 'Phuong trinh co 2 nghiem.',
        ),
      ],
    ),
  ];

  static List<MatchCardModel> matchCards() => [
    MatchCardModel(id: 1, pairId: 1, content: 'Delta', xpReward: 10),
    MatchCardModel(id: 2, pairId: 1, content: 'b^2 - 4ac', xpReward: 10),
    MatchCardModel(id: 3, pairId: 2, content: 'Dinh parabol', xpReward: 10),
    MatchCardModel(
      id: 4,
      pairId: 2,
      content: '(-b/2a, -Delta/4a)',
      xpReward: 10,
    ),
  ];

  static List<WrongQuestionModel> wrongQuestions() => [
    WrongQuestionModel(
      questionContent: 'x^2 - 5x + 6 = 0',
      userAnswerContent: 'x = 1, x = 6',
      correctAnswerContent: 'x = 2, x = 3',
    ),
  ];

  static ProfileResponse profile(int gradeId) => ProfileResponse(
    fullName: 'Hoc sinh demo',
    email: 'offline@example.com',
    avatarUrl: null,
    gradeName: 'Lop $gradeId',
    role: 'USER',
    isPremium: false,
    totalXp: 450,
    totalLesson: 9,
    streakDay: 3,
  );

  static UserInfoResponse userInfo(int gradeId) => UserInfoResponse(
    fullName: 'Hoc sinh demo',
    email: 'offline@example.com',
    phone: '',
    dob: '',
    avatarUrl: '',
    gradeName: 'Lop $gradeId',
    role: 'USER',
    isPremium: false,
  );
}
