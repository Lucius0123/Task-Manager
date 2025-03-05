import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../cards/task_itam_card.dart';
import '../services/task_service.dart';
import 'edit_task_screen.dart';
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskService _taskService = TaskService();
  late Map<DateTime, List<Task>> _tasksByDate;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tasksByDate = {};
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    List<Task> tasks =
        await _taskService
            .getTasks()
            .first; // Get the first emitted list of tasks
    Map<DateTime, List<Task>> groupedTasks = {};

    for (var task in tasks) {
      DateTime date = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      if (!groupedTasks.containsKey(date)) {
        groupedTasks[date] = [];
      }
      groupedTasks[date]!.add(task);
    }
    setState(() {
      _tasksByDate = groupedTasks;
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Calendar')),
      body: Column(
        children: [
          TableCalendar(
            rowHeight: 40,

            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getTasksForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        events.length > 3 ? 3 : events.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _selectedDay == null || _getTasksForDay(_selectedDay!).isEmpty
                    ? const Center(child: Text("No tasks for this day"))
                    : ListView(
                      children:
                          _getTasksForDay(_selectedDay!).map((task) {
                            return TaskItem(
                              task: task,
                              onToggle: () {},
                              onDelete: () {},
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(task: task),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }
}
