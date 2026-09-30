import 'package:flutter_test/flutter_test.dart';
import 'package:student_life/data/student_store.dart';

void main() {
  group('StudentTask', () {
    test('round trips all task fields through JSON', () {
      final original = StudentTask(
        title: 'Prepare presentation',
        dueDate: DateTime(2026, 9, 28, 10),
        isExam: true,
        done: true,
        priority: TaskPriority.high,
        repeat: TaskRepeat.weekly,
        category: 'Computer Science',
        notes: 'Bring the final slides.',
      );

      final restored = StudentTask.fromJson(original.toJson());

      expect(restored.title, original.title);
      expect(restored.dueDate, original.dueDate);
      expect(restored.isExam, isTrue);
      expect(restored.done, isTrue);
      expect(restored.priority, TaskPriority.high);
      expect(restored.repeat, TaskRepeat.weekly);
      expect(restored.category, original.category);
      expect(restored.notes, original.notes);
    });
  });

  test('expense preserves decimal amounts through JSON', () {
    final original = StudentExpense(
      'Lunch',
      12.50,
      DateTime(2026, 9, 28),
      category: 'Food',
      paymentMethod: 'Card',
      notes: 'Campus cafe',
    );

    final restored = StudentExpense.fromJson(original.toJson());

    expect(restored.amount, 12.50);
    expect(restored.category, 'Food');
    expect(restored.paymentMethod, 'Card');
    expect(restored.notes, 'Campus cafe');
  });

  test('schedule and event preserve optional details', () {
    final schedule = ClassSchedule(
      subject: 'Software Engineering',
      time: '08:00',
      room: 'B204',
      day: 'Tuesday',
      endTime: '10:00',
      instructor: 'Dr. Dara',
      notes: 'Bring laptop',
    );
    final event = CampusEvent(
      title: 'Career fair',
      date: '2026-10-02',
      place: 'Student Center',
      club: 'Career Office',
      description: 'Meet local employers.',
    );

    final restoredSchedule = ClassSchedule.fromJson(schedule.toJson());
    final restoredEvent = CampusEvent.fromJson(event.toJson());

    expect(restoredSchedule.endTime, '10:00');
    expect(restoredSchedule.instructor, 'Dr. Dara');
    expect(restoredSchedule.notes, 'Bring laptop');
    expect(restoredEvent.description, 'Meet local employers.');
  });

  test('attendance records preserve status and notes', () {
    final original = AttendanceRecord(
      course: 'Databases',
      date: DateTime(2026, 9, 28),
      status: AttendanceStatus.late,
      note: 'Arrived five minutes late.',
    );

    final restored = AttendanceRecord.fromJson(original.toJson());

    expect(restored.course, 'Databases');
    expect(restored.status, AttendanceStatus.late);
    expect(restored.note, original.note);
  });

  test('GPA uses credit-weighted points', () {
    final grades = [
      CourseGrade(course: 'Math', credits: 3, grade: 'A'),
      CourseGrade(course: 'Writing', credits: 1, grade: 'B'),
    ];

    final totalCredits = grades.fold<double>(
      0,
      (total, grade) => total + grade.credits,
    );
    final gpa = grades.fold<double>(
          0,
          (total, grade) => total + grade.points * grade.credits,
        ) /
        totalCredits;

    expect(gpa, 3.75);
  });

  test('invalid persisted grades safely fall back to F', () {
    final grade = CourseGrade.fromJson({
      'course': 'Unknown',
      'credits': 2,
      'grade': 'AB',
    });

    expect(grade.grade, 'F');
    expect(grade.points, 0);
  });
}
