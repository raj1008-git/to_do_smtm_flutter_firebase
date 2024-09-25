import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/sub_task.dart';
import '../Model/task_model.dart';
import '../Provider/task_provider.dart';

class TodoTiles extends StatefulWidget {
  final Task newTask;
  final VoidCallback callback;
  SubTask? subtask;

  TodoTiles({super.key, required this.newTask, required this.callback});

  @override
  State<TodoTiles> createState() => _TodoTilesState();
}

class _TodoTilesState extends State<TodoTiles> {
  // Text controller for editing task name
  TextEditingController editTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int numberOfSubTasks = widget.newTask.subtasks?.length ?? 0;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    List<SubTask>? subtasks = taskProvider.showSubTasks(widget.newTask);
    double totalSubTaskCount =
        taskProvider.getTotalSubTaskCount(widget.newTask).toDouble();
    double completedSubTaskCount =
        taskProvider.getCompletedSubTaskCount(widget.newTask).toDouble();

    double completionPercentage =
        taskProvider.getTaskCompletionPercentage(widget.newTask);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled:
              true, // Allow the bottom sheet to take the full height
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  // Make the content scrollable
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          widget.newTask.taskName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Sub Tasks',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // List of subtasks
                      Container(
                        // Adjust height as needed, this is for the ListView
                        child: subtasks != null && subtasks.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap:
                                    true, // Use shrinkWrap for better sizing
                                physics:
                                    const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                                itemCount: subtasks.length,
                                itemBuilder: (context, index) {
                                  final subtask = subtasks[index];
                                  return ListTile(
                                    title: Text(subtask.task),
                                    trailing: Consumer<TaskProvider>(
                                      builder: (context, taskProvider, child) {
                                        return IconButton(
                                          onPressed: () {
                                            taskProvider.checkCompletion(
                                                widget.newTask, index);
                                            setState(() {});
                                          },
                                          icon: subtasks[index].isCompleted
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.grey,
                                                ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text("No subtasks available"),
                              ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // Show another dialog when 'Add Subtask' button is pressed
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String subtaskName = ''; // Subtask input

                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text("Enter Subtask Name"),
                                content: TextField(
                                  onChanged: (value) {
                                    subtaskName =
                                        value; // Update the entered subtask name
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Subtask Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (subtaskName.isNotEmpty) {
                                        taskProvider.addSubTasksToTask(
                                          widget.newTask,
                                          SubTask(subtaskName, false),
                                        );
                                        totalSubTaskCount = taskProvider
                                            .getTotalSubTaskCount(
                                                widget.newTask)
                                            .toDouble();
                                        completedSubTaskCount = taskProvider
                                            .getCompletedSubTaskCount(
                                                widget.newTask)
                                            .toDouble();

                                        completionPercentage = taskProvider
                                            .getTaskCompletionPercentage(
                                                widget.newTask);
                                        widget.callback;
                                        setState(() {});
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      }
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Add Subtask",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 6,
                offset: const Offset(0, 4)),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task Image and Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: double.infinity,
              height: 135,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  topLeft: Radius.circular(25),
                ),
                image: DecorationImage(
                  image: AssetImage(widget.newTask.imageTheme),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: completionPercentage == 100.0
                        ? Colors.green
                        : Colors.grey,
                    child: Icon(
                      Icons.task,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.newTask.taskName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  Text(
                    '$numberOfSubTasks SubTasks',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Progress Bar
            Consumer<TaskProvider>(
              builder:
                  (BuildContext context, TaskProvider value, Widget? child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: totalSubTaskCount == 0
                              ? 0 // If total tasks are 0, set progress to 0
                              : (completedSubTaskCount /
                                  totalSubTaskCount), // Calculate progress
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                          minHeight: 5,
                        ),
                      ),
                      SizedBox(
                          width:
                              8), // Spacing between the progress bar and the text
                      Text(
                        '${completionPercentage.toStringAsFixed(1)}%', // Format percentage to 1 decimal
                        style: TextStyle(
                          fontSize: 20, // Adjust font size as needed
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Text(
            //   '${completionPercentage} %',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 10),
            // Row with icons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile avatars (example)
                  const SizedBox(
                    width: 100,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/raj.jpg'),
                          radius: 15,
                        ),
                        Positioned(
                          left: 20,
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/people/bill.jpeg'),
                            radius: 15,
                          ),
                        ),
                        Positioned(
                          left: 40,
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: Text(
                              '3+',
                              style: TextStyle(color: Colors.white),
                            ),
                            radius: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete and Edit Buttons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text("Confirm Delete?"),
                                content: const Text(
                                    "Are you sure you want to delete this task?"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Provider.of<TaskProvider>(context,
                                              listen: false)
                                          .removeTask(widget.newTask);
                                      Navigator.of(context).pop();
                                      widget.callback();
                                    },
                                    child: const Text("OK",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.delete,
                            color: Colors.red, size: 25),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          editTaskController.text = widget.newTask.taskName;

                          // Show dialog to edit the task name
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text("Edit Task"),
                                content: TextField(
                                  controller: editTaskController,
                                  decoration: const InputDecoration(
                                    labelText: 'Task Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Edit the task name in the provider
                                      Provider.of<TaskProvider>(context,
                                              listen: false)
                                          .editTaskName(widget.newTask.taskName,
                                              editTaskController.text);
                                      Navigator.of(context).pop();
                                      widget
                                          .callback(); // Refresh the UI after editing
                                    },
                                    child: const Text("Edit",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.edit_note_outlined,
                            color: Colors.blue, size: 25),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
