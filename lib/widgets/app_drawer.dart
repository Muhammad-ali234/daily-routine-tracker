import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: '/',
                  currentRoute: currentRoute,
                  tooltip: 'View your daily overview',
                ),
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    final uncompletedTasks = taskProvider.getTodayTasks().where((task) => !task.completed).length;
                    return _buildNavItem(
                      context: context,
                      icon: Icons.task_alt_rounded,
                      title: 'Tasks',
                      route: '/tasks',
                      currentRoute: currentRoute,
                      tooltip: 'Manage your tasks',
                      badge: uncompletedTasks > 0 ? '$uncompletedTasks' : null,
                    );
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.folder_rounded,
                  title: 'Projects',
                  route: '/projects',
                  currentRoute: currentRoute,
                  tooltip: 'View your projects',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.repeat_rounded,
                  title: 'Habits',
                  route: '/habits',
                  currentRoute: currentRoute,
                  tooltip: 'Track your habits',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.analytics_rounded,
                  title: 'Analytics',
                  route: '/analytics',
                  currentRoute: currentRoute,
                  tooltip: 'View your progress analytics',
                ),
                const Divider(height: 32),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  route: '/profile',
                  currentRoute: currentRoute,
                  tooltip: 'View and edit your profile',
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  route: '/settings',
                  currentRoute: currentRoute,
                  tooltip: 'Customize app settings',
                ),
                const Divider(height: 32),
                _buildNavItem(
                  context: context,
                  icon: Icons.help_rounded,
                  title: 'Help & Feedback',
                  onTap: () {
                    // TODO: Implement help & feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                  currentRoute: currentRoute,
                  tooltip: 'Get help or send feedback',
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return _buildNavItem(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          await userProvider.logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        }
                      },
                      currentRoute: currentRoute,
                      tooltip: 'Sign out of your account',
                    );
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'profile_image',
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      backgroundImage: userProvider.user?.profileImageUrl != null
                          ? NetworkImage(userProvider.user!.profileImageUrl!) as ImageProvider
                          : const AssetImage('assets/images/default_profile.png'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.user?.name ?? 'Guest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userProvider.user?.email ?? 'Not signed in',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      userProvider.user?.preferences['isPremium'] == true
                          ? Icons.star_rounded 
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userProvider.user?.preferences['isPremium'] == true ? 'Premium' : 'Free Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? route,
    required String currentRoute,
    String? tooltip,
    String? badge,
    VoidCallback? onTap,
  }) {
    final isSelected = route != null && (
      route == '/' ? currentRoute == '/' : currentRoute.startsWith(route)
    );
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Tooltip(
      message: tooltip ?? title,
      child: Material(
        color: isSelected 
            ? colorScheme.primary.withOpacity(0.12)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            if (route != null) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected 
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}