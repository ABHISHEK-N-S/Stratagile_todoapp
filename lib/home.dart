
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>with SingleTickerProviderStateMixin {
  // ..
  late Box<String> tasksBox;
  late Box<String> tasksBoxDesc;
  late Box<String> completedTasksBox;
  late Box<String> completedTasksBoxDesc;
  TextEditingController textFieldController = TextEditingController();
  TextEditingController textFieldDescController = TextEditingController();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tasksBox = Hive.box("tasksBox");
    tasksBoxDesc = Hive.box("tasksBoxDesc");
    completedTasksBox = Hive.box("completedTasksBox");
    completedTasksBoxDesc = Hive.box("completedTasksBoxDesc");
  }

  void onAddTask() {
    if (textFieldController.text.isNotEmpty) {
      tasksBox.add(textFieldController.text);
      tasksBoxDesc.add(textFieldDescController.text);

      Navigator.pop(context);
      textFieldController.clear();
      textFieldDescController.clear();
      return;
    }
  }

  void updateTask({required int index, required String newTask, required String newTaskDesc}) {
    if (index >= 0 && index < tasksBox.length) {
      // Retrieve the existing task data.
      String existingTask = tasksBox.getAt(index) ?? "";
      String existingTaskDesc = tasksBoxDesc.getAt(index) ?? "";

      // Modify the task data with the new values.
      existingTask = newTask;
      existingTaskDesc = newTaskDesc;

      // Save the updated data back to the Hive box.
      tasksBox.putAt(index, existingTask);
      tasksBoxDesc.putAt(index, existingTaskDesc);
      textFieldController.clear();
      textFieldDescController.clear();
      Navigator.pop(context);
    }
  }

  void onDeleteTask(int index) {
    tasksBox.deleteAt(index);
    tasksBoxDesc.deleteAt(index);
    return;
  }

  Widget emptyList() {
    return const Center(
      child: Text("Creata your own todos"),
    );
  }

  void showAddTaskBottomSheet(
      {required BuildContext context,
        required bool forUpdate,
        int? index,
        String? title,
        String? desc}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                forUpdate
                    ? const Text(
                  'Update Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : const Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: textFieldController,
                  decoration: forUpdate == true
                      ? InputDecoration(
                    hintText: title.toString(),
                    border: const OutlineInputBorder(),
                  )
                      : const InputDecoration(
                    hintText: "Enter task",
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: textFieldDescController,
                  maxLines: 5,
                  decoration: forUpdate
                      ? InputDecoration(
                    hintText: desc.toString(),
                    border: const OutlineInputBorder(),
                  )
                      : const InputDecoration(
                    hintText: "Enter Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        forUpdate ? updateTask(index: index!,newTask: textFieldController.text,newTaskDesc: textFieldDescController.text):
                        onAddTask();
                      },
                      child:
                      forUpdate ? const Text("Update") : const Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void markTaskAsCompleted(int index) {
    // Mark the task as completed.
    String task = tasksBox.getAt(index) ?? "";
    String taskDesc = tasksBoxDesc.getAt(index) ?? "";

    // Add the task to the "Completed" tab and its description.
    completedTasksBox.add(task);
    completedTasksBoxDesc.add(taskDesc);

    // Remove the task from the "Active" tab.
    tasksBox.deleteAt(index);
    tasksBoxDesc.deleteAt(index);
  }

  Widget _buildCompletedTasksView() {
    return ListView.builder(
      itemCount: completedTasksBox.length,
      itemBuilder: (context, index) {
        String task = completedTasksBox.getAt(index) ?? "";
        String taskDesc = completedTasksBoxDesc.getAt(index) ?? "";

        return Card(
          shadowColor: Colors.grey,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                title: Text(task),
                subtitle: Text(taskDesc),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    completedTasksBox.deleteAt(index);
                    completedTasksBoxDesc.deleteAt(index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: const Text(" Stratagile todos")),
        backgroundColor: hPrimaryColor,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ValueListenableBuilder<Box<String>>(
            valueListenable: tasksBox.listenable(),
            builder: (BuildContext context, Box<String> value, Widget? child) {
              if (tasksBox.length > 0) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                  ),
                  itemCount: tasksBox.length,
                  itemBuilder: (context, index) {
                    String task = tasksBox.getAt(index) ?? "";
                    String taskDesc = tasksBoxDesc.getAt(index) ?? "";


                    return Card(
                      shadowColor: Colors.grey,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(task),
                              subtitle: Text(taskDesc),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => onDeleteTask(index),
                              ),
                            ),
                          ),

                          TextButton(

                            onPressed: () {
                              markTaskAsCompleted(index);
                            },
                            child: const Text('Mark as Completed',style: textsyles,),
                          ),
                        ],
                      ),
                    );
                  },
                );

              } else {
                return emptyList();
              }
            },
          ),
          ValueListenableBuilder<Box<String>>(
            valueListenable: completedTasksBox.listenable(),
            builder: (BuildContext context, Box<String> value, Widget? child) {
              if (completedTasksBox.length > 0) {
                return _buildCompletedTasksView();
              } else {
                return emptyList();
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // ..
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: hPrimaryColor,
        onPressed: () => showAddTaskBottomSheet(
            context: context, forUpdate: false, index: 0),
        label: const Text("Add todo"),
      ),
    );
  }
}
