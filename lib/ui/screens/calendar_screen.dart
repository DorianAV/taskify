import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_dialog.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getTasksForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) {
      if (task.date == null) return false;
      try {
        final taskDate = DateTime.parse(task.date!);
        return isSameDay(taskDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void _showTaskDialog([Task? task]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );

    if (result != null) {
      if (task == null) {
        // If creating a new task from calendar, default to selected date
        String? date = result['date'];
        if (date == null && _selectedDay != null) {
          date = _selectedDay!.toIso8601String().split('T')[0];
        }

        ref.read(taskProvider.notifier).addTask(
          result['title']!,
          result['description']!,
          result['status'] as TaskStatus,
          date,
          result['time'],
        );
      } else {
        ref.read(taskProvider.notifier).updateTask(
              task.copyWith(
                title: result['title'],
                description: result['description'],
                status: result['status'] as TaskStatus,
                date: result['date'],
                time: result['time'],
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final allTasks = taskState.tasks;
    final selectedTasks = _getTasksForDay(_selectedDay!, allTasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            locale: 'es_ES',
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mes',
              CalendarFormat.twoWeeks: '2 Semanas',
              CalendarFormat.week: 'Semana',
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getTasksForDay(day, allTasks);
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selectedTasks.length,
              itemBuilder: (context, index) {
                final task = selectedTasks[index];
                return TaskTile(
                  task: task,
                  onToggle: () {
                    final newStatus = task.status == TaskStatus.completed
                        ? TaskStatus.pending
                        : TaskStatus.completed;
                    ref.read(taskProvider.notifier).updateTask(
                          task.copyWith(status: newStatus),
                        );
                  },
                  onDelete: () {
                    ref.read(taskProvider.notifier).deleteTask(task.id!);
                  },
                  onEdit: () => _showTaskDialog(task),
                  onStatusChange: () {
                    // Reuse the status change dialog logic from HomeScreen if possible,
                    // or duplicate it here for simplicity as it's small.
                    // For now, I'll skip it or implement a simple one.
                    // Let's implement a simple one.
                    showDialog<TaskStatus>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cambiar Estado'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: TaskStatus.values.map((status) {
                            return RadioListTile<TaskStatus>(
                              title: Text(Task.getStatusLabelStatic(status)),
                              value: status,
                              groupValue: task.status,
                              onChanged: (value) {
                                Navigator.pop(context, value);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ).then((newStatus) {
                      if (newStatus != null && newStatus != task.status) {
                        ref.read(taskProvider.notifier).updateTask(task.copyWith(status: newStatus));
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
