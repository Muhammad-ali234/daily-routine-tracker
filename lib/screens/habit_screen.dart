import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({Key? key}) : super(key: key);

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search habits...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium!.color,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Physical'),
              Tab(text: 'Mental'),
              Tab(text: 'Career'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHabitList(_getAllHabits),
                _buildHabitList((provider) => provider.getHabitsByCategory(HabitCategory.physical)),
                _buildHabitList((provider) => provider.getHabitsByCategory(HabitCategory.mental)),
                _buildHabitList((provider) => provider.getHabitsByCategory(HabitCategory.career)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Habit> _getAllHabits(HabitProvider provider) {
    final habits = provider.habits;
    if (_searchQuery.isEmpty) return habits;
    
    return habits.where((habit) => 
      habit.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Widget _buildHabitList(List<Habit> Function(HabitProvider) getFilteredHabits) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habits = getFilteredHabits(habitProvider);
        
        if (habits.isEmpty) {
          return const Center(
            child: Text('No habits found'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return _buildHabitCard(habit);
          },
        );
      },
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();
    
    bool isToday(String day) {
      return day.toLowerCase() == currentDay;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildCategoryChip(habit.category),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Streak: ${habit.currentStreak} days',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Longest: ${habit.longestStreak} days',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDayButton('M', habit.monday, isToday('monday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'monday');
                }),
                _buildDayButton('T', habit.tuesday, isToday('tuesday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'tuesday');
                }),
                _buildDayButton('W', habit.wednesday, isToday('wednesday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'wednesday');
                }),
                _buildDayButton('T', habit.thursday, isToday('thursday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'thursday');
                }),
                _buildDayButton('F', habit.friday, isToday('friday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'friday');
                }),
                _buildDayButton('S', habit.saturday, isToday('saturday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'saturday');
                }),
                _buildDayButton('S', habit.sunday, isToday('sunday'), () {
                  Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, 'sunday');
                }),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditHabitDialog(context, habit);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, habit);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(String day, bool completed, bool isToday, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? AppTheme.primaryColor : Colors.transparent,
          border: Border.all(
            color: isToday ? AppTheme.accentColor : AppTheme.primaryColor,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: completed ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(HabitCategory category) {
    Color chipColor;
    String label;
    
    switch (category) {
      case HabitCategory.physical:
        chipColor = Colors.green;
        label = 'Physical';
        break;
      case HabitCategory.mental:
        chipColor = Colors.blue;
        label = 'Mental';
        break;
      case HabitCategory.career:
        chipColor = Colors.purple;
        label = 'Career';
        break;
      case HabitCategory.social:
        chipColor = Colors.orange;
        label = 'Social';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController habitNameController = TextEditingController();
    HabitCategory category = HabitCategory.physical;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: habitNameController,
                      decoration: const InputDecoration(
                        labelText: 'Habit Name',
                        hintText: 'Enter habit name',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Category:'),
                    DropdownButton<HabitCategory>(
                      value: category,
                      isExpanded: true,
                      onChanged: (HabitCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            category = newValue;
                          });
                        }
                      },
                      items: HabitCategory.values.map((HabitCategory category) {
                        return DropdownMenuItem<HabitCategory>(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (habitNameController.text.trim().isNotEmpty) {
                      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                      final newHabit = Habit(
                        id: '', // Will be set by provider
                        name: habitNameController.text.trim(),
                        category: category,
                        createdAt: DateTime.now(),
                      );
                      
                      habitProvider.addHabit(newHabit);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add Habit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditHabitDialog(BuildContext context, Habit habit) {
    final TextEditingController habitNameController = TextEditingController(text: habit.name);
    HabitCategory category = habit.category;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: habitNameController,
                      decoration: const InputDecoration(
                        labelText: 'Habit Name',
                        hintText: 'Enter habit name',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Category:'),
                    DropdownButton<HabitCategory>(
                      value: category,
                      isExpanded: true,
                      onChanged: (HabitCategory? newValue) {
                        if (newValue != null) {
                          setState(() {
                            category = newValue;
                          });
                        }
                      },
                      items: HabitCategory.values.map((HabitCategory category) {
                        return DropdownMenuItem<HabitCategory>(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (habitNameController.text.trim().isNotEmpty) {
                      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                      final updatedHabit = Habit(
                        id: habit.id,
                        name: habitNameController.text.trim(),
                        category: category,
                        monday: habit.monday,
                        tuesday: habit.tuesday,
                        wednesday: habit.wednesday,
                        thursday: habit.thursday,
                        friday: habit.friday,
                        saturday: habit.saturday,
                        sunday: habit.sunday,
                        currentStreak: habit.currentStreak,
                        longestStreak: habit.longestStreak,
                        createdAt: habit.createdAt,
                      );
                      
                      habitProvider.updateHabit(updatedHabit);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Are you sure you want to delete "${habit.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                habitProvider.deleteHabit(habit.id);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}