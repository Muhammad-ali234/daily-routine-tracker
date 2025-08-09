import 'package:daily_routine_tracker/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: const Text('Tasks'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/tasks');
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Projects'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/projects');
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Habits'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/habits');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/analytics');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Feedback'),
            onTap: () {
              // TODO: Implement help & feedback
            },
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
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: userProvider.user.profileImageUrl != null
                    ? NetworkImage(userProvider.user.profileImageUrl!) as ImageProvider
                    : const AssetImage('assets/images/default_profile.png'),
              ),
              const SizedBox(height: 10),
              Text(
                userProvider.user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userProvider.user.email,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}