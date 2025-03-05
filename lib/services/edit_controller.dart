import 'package:flutter/material.dart';
import '../services/task_service.dart';
class EditController extends ChangeNotifier {
  // Form & service references
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();

  // State variables
  String title = '';
  String description = '';
  DateTime dueDate = DateTime.now();
  TimeOfDay dueTime = TimeOfDay.now();
  String priority = 'medium';
  List<String> tags = [];
  bool isLoading = false;

  // If editing an existing task
  Task? currentTask;

  EditController({this.currentTask}) {
    if (currentTask != null) {
      title = currentTask!.title;
      description = currentTask!.description;
      dueDate = currentTask!.dueDate;
      dueTime = TimeOfDay.fromDateTime(currentTask!.dueDate);
      priority = currentTask!.priority;
      tags = List.from(currentTask!.tags);
    }
  }

  // ------------------ Setters & State Updates ------------------ //

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setPriority(String value) {
    priority = value;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    notifyListeners();
  }

  // ------------------ Date & Time Pickers ------------------ //

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != dueDate) {
      dueDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: dueTime,
    );
    if (picked != null && picked != dueTime) {
      dueTime = picked;
      notifyListeners();
    }
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
  }

  // ------------------ Save Task ------------------ //

  Future<void> saveTask(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      final combinedDateTime = _combineDateAndTime();

      if (currentTask == null) {
        // Create new task
        final newTask = Task(
          id: '',
          title: title.trim(),
          description: description.trim(),
          dueDate: combinedDateTime,
          priority: priority,
          isCompleted: false,
          tags: tags,
        );
        await _taskService.addTask(newTask);
      } else {
        // Update existing task
        final updatedTask = Task(
          id: currentTask!.id,
          title: title.trim(),
          description: description.trim(),
          dueDate: combinedDateTime,
          priority: priority,
          isCompleted: currentTask!.isCompleted,
          tags: tags,
        );
        await _taskService.updateTask(updatedTask);
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
