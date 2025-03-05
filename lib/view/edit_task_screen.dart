import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/edit_controller.dart';
import '../services/task_service.dart';
import '../widgets/priority_selector.dart';
import '../widgets/tag_selector.dart';

class AddTaskScreen extends StatelessWidget {
  final Task? task;
  const AddTaskScreen({Key? key, this.task}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditController>(
      create: (_) => EditController(currentTask: task),
      child: const _AddTaskScreenView(),
    );
  }
}

class _AddTaskScreenView extends StatelessWidget {
  const _AddTaskScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editCtrl = Provider.of<EditController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(editCtrl.currentTask == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Form(
        key: editCtrl.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: editCtrl.title,
              onChanged: editCtrl.setTitle,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
              ),
              validator: (value) =>
              (value == null || value.isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              initialValue: editCtrl.description,
              onChanged: editCtrl.setDescription,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
              ),
              minLines: 5,
              maxLines: null,
            ),
            const SizedBox(height: 16),

            // Due Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => editCtrl.selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Due Date'),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(editCtrl.dueDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => editCtrl.selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Due Time'),
                      child: Text(editCtrl.dueTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Priority Selector
            const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            PrioritySelector(
              selectedPriority: editCtrl.priority,
              onPrioritySelected: editCtrl.setPriority,
            ),
            const SizedBox(height: 24),
            // Tags Selector
            const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TagsSelector(
              selectedTags: editCtrl.tags,
              availableTags: ['Work', 'Personal', 'Study', 'Shopping', 'Health'],
              onTagToggle: editCtrl.toggleTag,
            ),
            const SizedBox(height: 32),

            // Save Task Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: editCtrl.isLoading ? null : () => editCtrl.saveTask(context),
                child: editCtrl.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(editCtrl.currentTask == null ? 'Add Task' : 'Update Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
