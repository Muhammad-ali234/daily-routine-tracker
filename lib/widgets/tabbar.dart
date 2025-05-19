import 'package:flutter/material.dart';

class MyTabBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabNames;
  
  const MyTabBarWidget({
    super.key,
    required this.controller,
    required this.tabNames,
  });

  @override
  _MyTabBarWidgetState createState() => _MyTabBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}

class _MyTabBarWidgetState extends State<MyTabBarWidget> {
  final List<Color> gradientColors = [
    const Color(0xFF7B42F6), // left (darker purple)
    const Color(0xFFB01EFF), // right (lighter purple)
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {}); // Rebuild the widget when the tab changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final unselected = theme.textTheme.bodyMedium!.color;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.tabNames.length, (index) {
          final bool selected = widget.controller.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.controller.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    widget.tabNames[index],
                    style: TextStyle(
                      color: selected ? Colors.white : unselected,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}