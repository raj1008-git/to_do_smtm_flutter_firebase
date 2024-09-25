import 'package:todo_app/Model/sub_task.dart';

class Task {
  String taskName;
  String imageTheme;
  List<SubTask> subtasks = [];

  Task(
      {required this.taskName,
      required this.subtasks,
      required this.imageTheme});
}
