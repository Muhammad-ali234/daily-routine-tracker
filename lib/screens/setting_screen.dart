import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/project_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _notificationsEnabled = true;
  String _reminderTime = '08:00';
  bool _weeklyReportEnabled = true;
  String _weeklyReportDay = 'Sunday';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _reminderTime = _prefs.getString('reminder_time') ?? '08:00';
      _weeklyReportEnabled = _prefs.getBool('weekly_report_enabled') ?? true;
      _weeklyReportDay = _prefs.getString('weekly_report_day') ?? 'Sunday';
    });
  }
  
  Future<void> _savePreferences() async {
    await _prefs.setBool('notifications_enabled', _notificationsEnabled);
    await _prefs.setString('reminder_time', _reminderTime);
    await _prefs.setBool('weekly_report_enabled', _weeklyReportEnabled);
    await _prefs.setString('weekly_report_day', _weeklyReportDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const _SectionHeader(title: 'Appearance'),
                _buildThemeSelector(),
                const Divider(),
                
                const _SectionHeader(title: 'Notifications'),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive daily reminders for tasks and habits'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                      _savePreferences();
                    });
                  },
                ),
                ListTile(
                  title: const Text('Daily Reminder Time'),
                  subtitle: Text(_reminderTime),
                  trailing: const Icon(Icons.access_time),
                  enabled: _notificationsEnabled,
                  onTap: () async {
                    if (!_notificationsEnabled) return;
                    
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(_reminderTime.split(':')[0]),
                        minute: int.parse(_reminderTime.split(':')[1]),
                      ),
                    );
                    
                    if (picked != null) {
                      setState(() {
                        _reminderTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        _savePreferences();
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Test Notifications'),
                  subtitle: const Text('Test and manage app notifications'),
                  leading: const Icon(Icons.notifications_active),
                  onTap: () {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                ),
                const Divider(),
                
                const _SectionHeader(title: 'Reports'),
                SwitchListTile(
                  title: const Text('Weekly Report'),
                  subtitle: const Text('Receive a weekly summary of your progress'),
                  value: _weeklyReportEnabled,
                  onChanged: (value) {
                    setState(() {
                      _weeklyReportEnabled = value;
                      _savePreferences();
                    });
                  },
                ),
                ListTile(
                  title: const Text('Weekly Report Day'),
                  subtitle: Text(_weeklyReportDay),
                  enabled: _weeklyReportEnabled,
                  onTap: () {
                    if (!_weeklyReportEnabled) return;
                    
                    _showDayPicker();
                  },
                ),
                const Divider(),
                
                const _SectionHeader(title: 'Data Management'),
                ListTile(
                  title: const Text('Export Data'),
                  leading: const Icon(Icons.download),
                  subtitle: const Text('Save all your data to a file'),
                  onTap: () async {
                    await _exportData();
                  },
                ),
                ListTile(
                  title: const Text('Import Data'),
                  leading: const Icon(Icons.upload),
                  subtitle: const Text('Load data from a previously exported file'),
                  onTap: () async {
                    await _importData();
                  },
                ),
                ListTile(
                  title: const Text('Clear All Data'),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  subtitle: const Text('Delete all your tasks, habits and projects'),
                  onTap: () {
                    _showClearDataConfirmationDialog();
                  },
                ),
                const Divider(),
                
                const _SectionHeader(title: 'About'),
                const ListTile(
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                  leading: Icon(Icons.info),
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  leading: const Icon(Icons.description),
                  onTap: () {
                    // TODO: Navigate to terms of service
                  },
                ),
                const SizedBox(height: 24.0),
              ],
            ),
    );
  }

  Widget _buildThemeSelector() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            ListTile(
              title: const Text('Theme Mode'),
              subtitle: Text(_getThemeModeName(themeProvider.themeMode)),
              leading: const Icon(Icons.color_lens),
              onTap: () {
                _showThemeModeDialog(themeProvider);
              },
            ),
            ListTile(
              title: const Text('Primary Color'),
              subtitle: const Text('Change app accent color'),
              leading: CircleAvatar(
                backgroundColor: themeProvider.primaryColor,
                radius: 16,
              ),
              onTap: () {
                _showColorPickerDialog(themeProvider);
              },
            ),
          ],
        );
      },
    );
  }

  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await DataService.exportData(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await DataService.importData(context);
      
      if (success) {
        // Refresh providers to update UI
        Provider.of<TaskProvider>(context, listen: false).loadTasks();
        Provider.of<HabitProvider>(context, listen: false).loadHabits();
        Provider.of<ProjectProvider>(context, listen: false).loadProjects();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import data or no file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showThemeModeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showColorPickerDialog(ThemeProvider themeProvider) {
    final colors = [
      AppTheme.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Primary Color'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colors.map((color) {
              return InkWell(
                onTap: () {
                  themeProvider.setPrimaryColor(color);
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 20,
                  child: themeProvider.primaryColor == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDayPicker() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Weekly Report Day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: days.map((day) {
              return RadioListTile<String>(
                title: Text(day),
                value: day,
                groupValue: _weeklyReportDay,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _weeklyReportDay = value;
                      _savePreferences();
                    });
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to clear all data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  final success = await DataService.clearAllData();
                  
                  if (success) {
                    // Refresh providers to update UI
                    Provider.of<TaskProvider>(context, listen: false).loadTasks();
                    Provider.of<HabitProvider>(context, listen: false).loadHabits();
                    Provider.of<ProjectProvider>(context, listen: false).loadProjects();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data has been cleared')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to clear data')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All Data'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
        ),
      ),
    );
  }
}