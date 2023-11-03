import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stratagile_todo/home.dart';

import 'constants.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>("tasksBox");
  await Hive.openBox<String>("tasksBoxDesc");
  await Hive.openBox<String>("completedTasksBox"); // Create a box for completed tasks
  await Hive.openBox<String>("completedTasksBoxDesc");
  runApp(MaterialApp(
    home: const MyApp(),
    theme: ThemeData(primaryColor: hPrimaryColor),
    debugShowCheckedModeBanner: false,
  ));
}
