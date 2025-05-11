import 'package:flutter/material.dart';

class SourceTypeTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  const SourceTypeTabs({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => TabBar(
        controller: controller,
        isScrollable: true,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(icon: Icon(Icons.insert_drive_file), text: 'File'),
          Tab(icon: Icon(Icons.language), text: 'Web'),
          Tab(icon: Icon(Icons.cloud), text: 'Drive'),
          Tab(icon: Icon(Icons.forum), text: 'Slack'),
          Tab(icon: Icon(Icons.book_online), text: 'Confluence'),
        ],
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
