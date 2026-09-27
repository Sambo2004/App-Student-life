import 'package:flutter/widgets.dart';

/// Small offline dictionary for the app-owned interface text.
///
/// Flutter localizes framework controls through MaterialLocalizations, while
/// this dictionary handles labels written by Student Life Hub itself.
class AppLocalizations {
  const AppLocalizations._();

  static String text(BuildContext context, String english) {
    if (Localizations.localeOf(context).languageCode != 'km') return english;
    if (english.startsWith('Good morning, ')) {
      return 'អរុណសួស្តី, ${english.substring('Good morning, '.length)}';
    }
    return _khmer[english] ?? english;
  }

  static const _khmer = <String, String>{
    'Home': 'ទំព័រដើម',
    'Schedule': 'កាលវិភាគ',
    'Tasks': 'កិច្ចការ',
    'Budget': 'ថវិកា',
    'Events': 'ព្រឹត្តិការណ៍',
    'Profile': 'ប្រវត្តិរូប',
    'Planner': 'អ្នករៀបចំផែនការ',
    'Report': 'របាយការណ៍',
    'Quick add': 'បន្ថែមរហ័ស',
    'View all tasks': 'មើលកិច្ចការទាំងអស់',
    'Add task': 'បន្ថែមកិច្ចការ',
    'Add class': 'បន្ថែមថ្នាក់',
    'Add event': 'បន្ថែមព្រឹត្តិការណ៍',
    'Add expense': 'បន្ថែមចំណាយ',
    'Add assignment or exam': 'បន្ថែមកិច្ចការ ឬការប្រឡង',
    'Add a task title first.': 'សូមបញ្ចូលចំណងជើងកិច្ចការជាមុនសិន។',
    'Complete all class fields.': 'សូមបំពេញព័ត៌មានថ្នាក់ទាំងអស់។',
    'Complete all event fields.': 'សូមបំពេញព័ត៌មានព្រឹត្តិការណ៍ទាំងអស់។',
    'Due date': 'ថ្ងៃកំណត់',
    'Date': 'កាលបរិច្ឆេទ',
    'Time': 'ពេលវេលា',
    'Start time': 'ពេលចាប់ផ្តើម',
    'End time': 'ពេលបញ្ចប់',
    'Cancel': 'បោះបង់',
    'Save': 'រក្សាទុក',
    'Add': 'បន្ថែម',
    'Delete': 'លុប',
    'Edit': 'កែសម្រួល',
    'Open': 'កំពុងធ្វើ',
    'Done': 'រួចរាល់',
    'All': 'ទាំងអស់',
    'No classes added yet.': 'មិនទាន់មានថ្នាក់នៅឡើយទេ។',
    'No events added yet.': 'មិនទាន់មានព្រឹត្តិការណ៍នៅឡើយទេ។',
    'Nothing planned for this day.': 'មិនមានអ្វីបានរៀបចំសម្រាប់ថ្ងៃនេះទេ។',
    'Text size': 'ទំហំអក្សរ',
    'Font style': 'រចនាប័ទ្មអក្សរ',
    'Appearance': 'រូបរាង',
    'Language': 'ភាសា',
    'High contrast': 'កម្រិតពណ៌ខ្ពស់',
    'English': 'អង់គ្លេស',
    'Khmer': 'ខ្មែរ',
    'Backup data': 'បម្រុងទុកទិន្នន័យ',
    'Restore data': 'ស្តារទិន្នន័យ',
    'Study streak': 'ទម្លាប់សិក្សា',
    'Weekly report': 'របាយការណ៍ប្រចាំសប្តាហ៍',
    'Focus timer': 'កម្មវិធីកំណត់ពេលផ្តោតអារម្មណ៍',
    'Grades and GPA': 'ពិន្ទុ និង GPA',
    'About us': 'អំពីយើង',
    'Sponsors & partners': 'អ្នកឧបត្ថម្ភ និងដៃគូ',
    'Export calendar': 'នាំចេញកាលវិភាគ',
    'Export report': 'នាំចេញរបាយការណ៍',
    'Reset app data': 'កំណត់ទិន្នន័យកម្មវិធីឡើងវិញ',
    'Copy backup': 'ចម្លងការបម្រុងទុក',
    'Restore backup': 'ស្តារការបម្រុងទុក',
    'Word': 'Word',
    'PDF': 'PDF',
    'Overall progress': 'វឌ្ឍនភាពសរុប',
    'of your tasks are complete.': 'នៃកិច្ចការរបស់អ្នកបានបញ្ចប់។',
    'Completed': 'បានបញ្ចប់',
    'Open task': 'កិច្ចការកំពុងធ្វើ',
    'Backup copied to clipboard.': 'បានចម្លងការបម្រុងទុកទៅក្ដារតម្បៀតខ្ទាស់។',
    'Backup restored successfully.': 'បានស្តារការបម្រុងទុកដោយជោគជ័យ។',
    'Could not export the calendar.': 'មិនអាចនាំចេញកាលវិភាគបានទេ។',
    'About Student Life Hub': 'អំពី Student Life Hub',
    'A simpler way to manage student life.': 'វិធីសាមញ្ញសម្រាប់គ្រប់គ្រងជីវិតនិស្សិត។',
    'Expense tracker': 'តាមដានចំណាយ',
    'Keep your student budget clear.': 'គ្រប់គ្រងថវិការបស់អ្នកឱ្យបានច្បាស់។',
    'Campus events': 'ព្រឹត្តិការណ៍ក្នុងបរិវេណសិក្សា',
    'Discover clubs and activities.': 'ស្វែងរកក្លឹប និងសកម្មភាពផ្សេងៗ។',
    'Work in focused blocks and take intentional breaks.': 'ធ្វើការជាផ្នែកៗដោយផ្តោតអារម្មណ៍ និងសម្រាកតាមពេលវេលា។',
    'Backup & restore': 'បម្រុងទុក និងស្តារ',
    'Keep a copy of your student data when you need it.': 'រក្សាទុកច្បាប់ចម្លងទិន្នន័យរបស់អ្នកនៅពេលត្រូវការ។',
    'Track course results and your weighted GPA.': 'តាមដានលទ្ធផលមុខវិជ្ជា និង GPA របស់អ្នក។',
    'Weekly planner': 'ផែនការប្រចាំសប្តាហ៍',
    'See classes and deadlines together.': 'មើលថ្នាក់ និងថ្ងៃកំណត់នៅកន្លែងតែមួយ។',
    'A simple reflection on your current routine.': 'ការឆ្លុះបញ្ចាំងខ្លីអំពីទម្លាប់បច្ចុប្បន្នរបស់អ្នក។',
    'Small daily progress becomes a strong habit.': 'ការរីកចម្រើនតិចតួចរាល់ថ្ងៃក្លាយជាទម្លាប់រឹងមាំ។',
    'Our sponsors': 'អ្នកឧបត្ថម្ភរបស់យើង',
    'Supporting better student experiences.': 'គាំទ្របទពិសោធន៍និស្សិតឱ្យកាន់តែប្រសើរ។',
    'Class timetable': 'តារាងពេលវេលាថ្នាក់',
    'Your weekly class plan.': 'ផែនការថ្នាក់ប្រចាំសប្តាហ៍របស់អ្នក។',
    'Assignments & exams': 'កិច្ចការ និងការប្រឡង',
    'Never miss a deadline.': 'កុំឱ្យខកខានថ្ងៃកំណត់។',
    'Profile & settings': 'ប្រវត្តិរូប និងការកំណត់',
    'Make Student Life Hub feel like yours.': 'កែ Student Life Hub ឱ្យសមនឹងអ្នក។',
    'Here is your day at a glance.': 'នេះជាទិដ្ឋភាពសង្ខេបនៃថ្ងៃរបស់អ្នក។',
  };
}

extension AppLocalizationContext on BuildContext {
  String tr(String english) => AppLocalizations.text(this, english);
}
