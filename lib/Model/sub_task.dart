class SubTask {
  String task;
  bool isCompleted = false;
  SubTask(this.task, this.isCompleted);

  void toggleSubTask() {
    isCompleted = !isCompleted;
  }
}
