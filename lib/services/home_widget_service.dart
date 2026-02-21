import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class HomeWidgetService {
  static const String _groupId = 'group.ascendly_widget'; // For iOS
  static const String _androidWidgetName = 'AscendlyWidgetProvider';

  static Future<void> updateStreak(DateTime? startDate) async {
    if (startDate == null) return;

    final diff = DateTime.now().difference(startDate);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    
    // Save data for the widget
    await HomeWidget.saveWidgetData<String>('streak_days', days.toString());
    await HomeWidget.saveWidgetData<String>('streak_text', '${days}d ${hours}h');
    await HomeWidget.saveWidgetData<String>('last_update', DateFormat('HH:mm').format(DateTime.now()));

    // Trigger update
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: 'AscendlyWidget',
    );
  }
}
