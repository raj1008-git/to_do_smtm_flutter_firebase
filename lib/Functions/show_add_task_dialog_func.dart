import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/Model/task_model.dart';

import '../Provider/task_provider.dart';

class ShowAddTaskDialogFunc extends StatelessWidget {
  final VoidCallback onTaskAdded;
  const ShowAddTaskDialogFunc({super.key, required this.onTaskAdded});
  Future<void> showAddTaskDialog(
      BuildContext context,
      TextEditingController taskNameController,
      TextEditingController taskDescriptionController,
      DateTime? startDate,
      DateTime? endDate) async {
    var randomNumber = Random().nextInt(4);

    // List of theme images
    List<String> imagePath = [
      'assets/themes/blue_three.jpg',
      'assets/themes/green_three.jpg',
      'assets/themes/pink_three.jpg',
      'assets/themes/yellow_three.jpg'
    ];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text(
                'Add New Task',
                style: TextStyle(color: Colors.blue, fontSize: 30),
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(fontSize: 20),
                        controller: taskNameController,
                        decoration: const InputDecoration(
                          hintText: "Task Name",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: taskDescriptionController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Task Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Start Date Input Field
                      TextFormField(
                        readOnly: true, // Prevent manual editing
                        decoration: InputDecoration(
                          hintText: startDate != null
                              ? 'Start Date: ${startDate!.day}/${startDate!.month}/${startDate!.year}'
                              : 'Select Start Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null && picked != startDate) {
                                setState(() {
                                  startDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // End Date Input Field
                      TextFormField(
                        readOnly: true, // Prevent manual editing
                        decoration: InputDecoration(
                          hintText: endDate != null
                              ? 'End Date: ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                              : 'Select End Date',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null && picked != endDate) {
                                setState(() {
                                  endDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 10),
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    final eventProvider =
                        Provider.of<TaskProvider>(context, listen: false);
                    String taskName = taskNameController.text;
                    String taskDescription = taskDescriptionController.text;
                    Task newTask = Task(
                        taskName: taskName,
                        imageTheme: imagePath[randomNumber],
                        subtasks: []);
                    // Handle task creation here
                    eventProvider.addNewTask(newTask);
                    onTaskAdded();
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
