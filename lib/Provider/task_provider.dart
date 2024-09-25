import 'package:flutter/cupertino.dart';

import '../Model/sub_task.dart';
import '../Model/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _savedTasks = [];

  List<Task> get savedTasks => _savedTasks;

  // Add a new task
  void addNewTask(Task task) {
    _savedTasks.add(task);
    notifyListeners();
  }

  // Remove a task
  void removeTask(Task task) {
    _savedTasks.removeWhere((t) => t.taskName == task.taskName);
    notifyListeners();
  }

  // Edit the task name of an existing task
  void editTaskName(String oldTaskName, String newTaskName) {
    int taskIndex =
        _savedTasks.indexWhere((task) => task.taskName == oldTaskName);
    if (taskIndex != -1) {
      _savedTasks[taskIndex].taskName = newTaskName;
      notifyListeners();
    }
  }

  // Add subtasks to a specific task
  void addSubTasksToTask(Task task, SubTask subTask) {
    // Find the task by taskName
    int taskIndex = _savedTasks.indexWhere((t) => t.taskName == task.taskName);

    if (taskIndex != -1) {
      _savedTasks[taskIndex].subtasks.add(subTask);
    }
    notifyListeners();
  }

  List<SubTask>? showSubTasks(Task task) {
    int taskIndex = _savedTasks.indexWhere((t) => t.taskName == task.taskName);
    if (taskIndex != -1) {
      return _savedTasks[taskIndex].subtasks;
    }
    return null;
  }

  void checkCompletion(Task task, int index) {
    // Find the task by taskName
    int taskIndex = _savedTasks.indexWhere((t) => t.taskName == task.taskName);

    if (taskIndex != -1) {
      _savedTasks[taskIndex].subtasks[index].toggleSubTask();
      notifyListeners();
    }
  }

  double getTaskCompletionPercentage(Task task) {
    // Find the task by taskName in the saved tasks
    int taskIndex = _savedTasks.indexWhere((t) => t.taskName == task.taskName);

    // If the task exists
    if (taskIndex != -1) {
      List<SubTask> subtasks = _savedTasks[taskIndex].subtasks;

      // If there are no subtasks, return 0% completion
      if (subtasks.isEmpty) return 0;

      // Count the completed subtasks
      int completedSubTasks =
          subtasks.where((subTask) => subTask.isCompleted).length;

      // Calculate the completion percentage
      double percentage = (completedSubTasks / subtasks.length) * 100;

      return percentage;
    }

    // If task is not found, return 0
    return 0;
  }

  int getTotalSubTaskCount(Task task) {
    // Find the task by taskName in the saved tasks
    int taskIndex = _savedTasks.indexWhere((t) => t.taskName == task.taskName);

    // If the task exists, return the total number of subtasks
    if (taskIndex != -1) {
      return _savedTasks[taskIndex].subtasks.length;
    }
    notifyListeners();

    // If task is not found, return 0
    return 0;
  }

  int getCompletedSubTaskCount(Task task) {
    // Find the task by taskName in the saved tasks
    int taskIndex = _savedTasks.indexWhere((t) => t.taskName == task.taskName);

    // If the task exists
    if (taskIndex != -1) {
      List<SubTask> subtasks = _savedTasks[taskIndex].subtasks;

      // Count the number of completed subtasks
      int completedSubTasks =
          subtasks.where((subTask) => subTask.isCompleted).length;

      return completedSubTasks;
    }
    notifyListeners();
    // If task is not found, return 0
    return 0;
  }

  int getTotalTaskCount() {
    return _savedTasks.length;
  }

  @override
  notifyListeners();
}
