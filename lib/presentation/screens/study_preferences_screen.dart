import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_preferences_provider.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_helper.dart';

class StudyPreferencesScreen extends StatefulWidget {
  const StudyPreferencesScreen({super.key});

  @override
  State<StudyPreferencesScreen> createState() => _StudyPreferencesScreenState();
}

class _StudyPreferencesScreenState extends State<StudyPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize preferences when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyPreferencesProvider>().initializePreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Preferences'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.getBackgroundPrimary(context),
      body: Consumer<StudyPreferencesProvider>(
        builder: (context, studyPrefs, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  'Daily Study Reminder',
                  [
                    _buildReminderTimeCard(context, studyPrefs),
                  ],
                ),
                _buildSection(
                  context,
                  'Study Session Duration',
                  [
                    _buildSessionDurationCard(context, studyPrefs),
                  ],
                ),
                _buildSection(
                  context,
                  'Notifications',
                  [
                    _buildNotificationCard(context, studyPrefs),
                  ],
                ),
                _buildSection(
                  context,
                  'Sound Settings',
                  [
                    _buildSoundCard(context, studyPrefs),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReminderTimeCard(BuildContext context, StudyPreferencesProvider studyPrefs) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: AppColors.dominantPurple,
        ),
        title: Text(
          'Daily Reminder Time',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        subtitle: Text(
          'Set when you want to be reminded to study',
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
          ),
        ),
        trailing: Text(
          studyPrefs.getFormattedReminderTime(context),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.dominantPurple,
          ),
        ),
        onTap: () => _showTimePickerDialog(context, studyPrefs),
      ),
    );
  }

  Widget _buildSessionDurationCard(BuildContext context, StudyPreferencesProvider studyPrefs) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.timer,
          color: AppColors.dominantPurple,
        ),
        title: Text(
          'Study Session Duration',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        subtitle: Text(
          'Set your preferred study session length',
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
          ),
        ),
        trailing: Text(
          studyPrefs.formattedSessionDuration,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.dominantPurple,
          ),
        ),
        onTap: () => _showDurationPickerDialog(context, studyPrefs),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, StudyPreferencesProvider studyPrefs) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: AppColors.dominantPurple,
        ),
        title: Text(
          'Push Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        subtitle: Text(
          'Receive study reminders and updates',
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
          ),
        ),
        trailing: Switch(
          value: studyPrefs.notificationsEnabled,
          onChanged: (value) async {
            await studyPrefs.updateNotificationsEnabled(value);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Notifications enabled' : 'Notifications disabled',
                  ),
                  backgroundColor: AppColors.dominantPurple,
                ),
              );
            }
          },
          activeColor: AppColors.dominantPurple,
        ),
      ),
    );
  }

  Widget _buildSoundCard(BuildContext context, StudyPreferencesProvider studyPrefs) {
    return Card(
      color: AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.volume_up,
          color: AppColors.dominantPurple,
        ),
        title: Text(
          'Sound Effects',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        subtitle: Text(
          'Enable app sound effects',
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
          ),
        ),
        trailing: Switch(
          value: studyPrefs.soundEnabled,
          onChanged: (value) async {
            await studyPrefs.updateSoundEnabled(value);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Sound effects enabled' : 'Sound effects disabled',
                  ),
                  backgroundColor: AppColors.dominantPurple,
                ),
              );
            }
          },
          activeColor: AppColors.dominantPurple,
        ),
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context, StudyPreferencesProvider studyPrefs) {
    showTimePicker(
      context: context,
      initialTime: studyPrefs.dailyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.dominantPurple,
            ),
          ),
          child: child!,
        );
      },
    ).then((time) async {
      if (time != null) {
        await studyPrefs.updateDailyReminderTime(time);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder time set to ${time.format(context)}'),
              backgroundColor: AppColors.dominantPurple,
            ),
          );
        }
      }
    });
  }

  void _showDurationPickerDialog(BuildContext context, StudyPreferencesProvider studyPrefs) {
    final durations = [15, 30, 45, 60, 90, 120]; // minutes
    final currentDuration = studyPrefs.studySessionDuration;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Study Session Duration'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: durations.length,
            itemBuilder: (context, index) {
              final duration = durations[index];
              final isSelected = duration == currentDuration;
              String durationText;
              if (duration < 60) {
                durationText = '$duration minutes';
              } else {
                final hours = duration ~/ 60;
                final minutes = duration % 60;
                if (minutes == 0) {
                  durationText = '$hours hour${hours > 1 ? 's' : ''}';
                } else {
                  durationText = '$hours hour${hours > 1 ? 's' : ''} $minutes minutes';
                }
              }

              return ListTile(
                title: Text(durationText),
                trailing: isSelected ? Icon(Icons.check, color: AppColors.dominantPurple) : null,
                onTap: () {
                  studyPrefs.updateStudySessionDuration(duration);
                  Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Study session duration set to $durationText'),
                        backgroundColor: AppColors.dominantPurple,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
