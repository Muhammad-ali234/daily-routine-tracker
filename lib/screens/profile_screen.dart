import 'package:daily_routine_tracker/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.user?.name);
    _emailController = TextEditingController(text: userProvider.user?.email);
    _bioController = TextEditingController(text: userProvider.user?.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState?.validate() ?? false) {
                  _saveProfile();
                }
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer4<UserProvider, TaskProvider, ProjectProvider, HabitProvider>(
        builder: (context, userProvider, taskProvider, projectProvider, habitProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildUserStats(taskProvider, projectProvider, habitProvider),
                const SizedBox(height: 24),
                _buildProfileForm(user),
                const SizedBox(height: 24),
                _buildPreferences(userProvider),
                const SizedBox(height: 24),
                _buildDangerZone(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile_image',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : (user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : const AssetImage('assets/images/default_profile.png'))
                          as ImageProvider,
                ),
              ),
              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      color: Colors.white,
                      onPressed: _pickImage,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isEditing) ...[
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUserStats(
    TaskProvider taskProvider,
    ProjectProvider projectProvider,
    HabitProvider habitProvider,
  ) {
    final completedTasks = taskProvider.tasks.where((t) => t.completed).length;
    final activeProjects = projectProvider.activeProjects.length;
    final activeHabits = habitProvider.habits.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          'Completed Tasks',
          completedTasks.toString(),
          Icons.task_alt,
          Colors.green,
        ),
        _buildStatCard(
          'Active Projects',
          activeProjects.toString(),
          Icons.folder,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Habits',
          activeHabits.toString(),
          Icons.repeat,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(User user) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
              hintText: 'Tell us about yourself',
            ),
            enabled: _isEditing,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences(UserProvider userProvider) {
    final preferences = userProvider.user?.preferences ?? {};
    final dailyTaskGoal = preferences['dailyTaskGoal'] as int? ?? 5;
    final workStartTime = preferences['workStartTime'] as String? ?? '09:00';
    final workEndTime = preferences['workEndTime'] as String? ?? '17:00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Daily Task Goal'),
          subtitle: Text('$dailyTaskGoal tasks per day'),
          trailing: _isEditing
              ? SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: dailyTaskGoal.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final newValue = int.tryParse(value);
                      if (newValue != null) {
                        userProvider.updatePreference('dailyTaskGoal', newValue);
                      }
                    },
                  ),
                )
              : null,
        ),
        ListTile(
          title: const Text('Work Start Time'),
          subtitle: Text(workStartTime),
          trailing: _isEditing
              ? TextButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(workStartTime.split(':')[0]),
                        minute: int.parse(workStartTime.split(':')[1]),
                      ),
                    );
                    if (picked != null) {
                      final newTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      userProvider.updatePreference('workStartTime', newTime);
                    }
                  },
                  child: const Text('Change'),
                )
              : null,
        ),
        ListTile(
          title: const Text('Work End Time'),
          subtitle: Text(workEndTime),
          trailing: _isEditing
              ? TextButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(workEndTime.split(':')[0]),
                        minute: int.parse(workEndTime.split(':')[1]),
                      ),
                    );
                    if (picked != null) {
                      final newTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      userProvider.updatePreference('workEndTime', newTime);
                    }
                  },
                  child: const Text('Change'),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Delete Account'),
          subtitle: const Text('This action cannot be undone'),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: _showDeleteAccountDialog,
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Update user data
    await userProvider.updateUser(
      name: _nameController.text,
      email: _emailController.text,
      bio: _bioController.text,
      profileImageFile: _imageFile,
    );

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.deleteAccount();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
