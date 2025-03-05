import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/services/auth_services.dart';
import '../cards/task_itam_card.dart';
import '../services/task_service.dart';
import '../widgets/filter_chip_widget.dart';
import 'calendar_view.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _authService =AuthService();
  String? _priorityFilter;
  bool? _completionFilter;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      overlayColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list_rounded, color: Colors.white,size: 20,),
                        Text(
                          'Filter',
                          style: TextStyle(fontSize: 12,),
                        ),
                      ],
                    ),
                    onPressed: () {
                      _showFilterOptions();
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'My tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today, ${DateFormat('d MMM').format(DateTime.now())}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      overlayColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<AuthService>(context, listen: false).handleLogoutButton(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_outlined,color: Colors.white,size: 20,),
                        Text(
                          'Logout',
                          style: TextStyle(fontSize: 12,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: StreamBuilder<List<Task>>(
                  stream:
                  _priorityFilter != null || _completionFilter != null
                      ? _taskService.getFilteredTasks(
                    priority: _priorityFilter,
                    isCompleted: _completionFilter,
                  )
                      : _taskService.getTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final tasks = snapshot.data ?? [];

                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tasks yet. Add your first task!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    // Group tasks by date
                    final today = DateTime.now();
                    final tomorrow = DateTime(today.year, today.month, today.day + 1,);
                    final thisWeek = DateTime(today.year, today.month, today.day + 7,);
                    final n = DateTime(today.year, today.month, today.day + 2,);
                    final nextWeek = DateTime(today.year, today.month, today.day + 14,);
                    final todayTasks =
                    tasks.where((task) {
                      return task.dueDate.year == today.year &&
                          task.dueDate.month == today.month &&
                          task.dueDate.day == today.day;
                    }).toList();

                    final tomorrowTasks =
                    tasks.where((task) {
                      return task.dueDate.year == tomorrow.year &&
                          task.dueDate.month == tomorrow.month &&
                          task.dueDate.day == tomorrow.day;
                    }).toList();

                    final thisWeekTasks =
                    tasks.where((task) {
                      return task.dueDate.isAfter(n) &&
                          task.dueDate.isBefore(thisWeek);
                    }).toList();
                    final nextWeekTasks =
                    tasks.where((task) {
                      return task.dueDate.isAfter(thisWeek) &&
                          task.dueDate.isBefore(nextWeek);
                    }).toList();

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (todayTasks.isNotEmpty) ...[
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...todayTasks.map(
                                (task) => TaskItem(
                              task: task,
                              onToggle: () {
                                _taskService.toggleTaskCompletion(
                                  task.id,
                                  task.isCompleted,
                                );
                              },
                              onDelete: () {
                                _taskService.deleteTask(task.id);
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(task: task),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (tomorrowTasks.isNotEmpty) ...[
                          const Text(
                            'Tomorrow',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...tomorrowTasks.map(
                                (task) => TaskItem(
                              task: task,
                              onToggle: () {
                                _taskService.toggleTaskCompletion(
                                  task.id,
                                  task.isCompleted,
                                );
                              },
                              onDelete: () {
                                _taskService.deleteTask(task.id);
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(task: task),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (thisWeekTasks.isNotEmpty) ...[
                          const Text(
                            'This week',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...thisWeekTasks.map(
                                (task) => TaskItem(
                              task: task,
                              onToggle: () {
                                _taskService.toggleTaskCompletion(
                                  task.id,
                                  task.isCompleted,
                                );
                              },
                              onDelete: () {
                                _taskService.deleteTask(task.id);
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(task: task),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        if (nextWeekTasks.isNotEmpty) ...[
                          const Text(
                            'Next week',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...nextWeekTasks.map(
                                (task) => TaskItem(
                              task: task,
                              onToggle: () {
                                _taskService.toggleTaskCompletion(
                                  task.id,
                                  task.isCompleted,
                                );
                              },
                              onDelete: () {
                                _taskService.deleteTask(task.id);
                              },
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(task: task),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            // Calendar
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CalendarScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Priority',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChipWidget(
                        label: 'All',
                        selected: _priorityFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _priorityFilter = null;
                          });
                          this.setState(() {});
                        },
                      ),
                      FilterChipWidget(
                        label: 'High',
                        selected: _priorityFilter == 'high',
                        onSelected: (selected) {
                          setState(() {
                            _priorityFilter = selected ? 'high' : null;
                          });
                          this.setState(() {});
                        },
                      ),
                      FilterChipWidget(
                        label: 'Medium',
                        selected: _priorityFilter == 'medium',
                        onSelected: (selected) {
                          setState(() {
                            _priorityFilter = selected ? 'medium' : null;
                          });
                          this.setState(() {});
                        },
                      ),
                      FilterChipWidget(
                        label: 'Low',
                        selected: _priorityFilter == 'low',
                        onSelected: (selected) {
                          setState(() {
                            _priorityFilter = selected ? 'low' : null;
                          });
                          this.setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChipWidget(
                        label: 'All',
                        selected: _completionFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _completionFilter = null;
                          });
                          this.setState(() {});
                        },
                      ),
                      FilterChipWidget(
                        label: 'Completed',
                        selected: _completionFilter == true,
                        onSelected: (selected) {
                          setState(() {
                            _completionFilter = selected ? true : null;
                          });
                          this.setState(() {});
                        },
                      ),
                      FilterChipWidget(
                        label: 'Incomplete',
                        selected: _completionFilter == false,
                        onSelected: (selected) {
                          setState(() {
                            _completionFilter = selected ? false : null;
                          });
                          this.setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _priorityFilter = null;
                          _completionFilter = null;
                        });
                        this.setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


}