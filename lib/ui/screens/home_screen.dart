import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when screen loads
    Future.microtask(() => ref.read(taskProvider.notifier).fetchTasks());
  }

  void _showTaskDialog([Task? task]) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );

    if (result != null) {
      if (task == null) {
        ref.read(taskProvider.notifier).addTask(result['title']!, result['description']!);
      } else {
        ref.read(taskProvider.notifier).updateTask(
              task.copyWith(
                title: result['title'],
                description: result['description'],
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final tasks = taskState.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Taskify',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: TaskFilter.values.map((filter) {
                final isSelected = taskState.filter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter.name.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(taskProvider.notifier).setFilter(filter);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Task List
          Expanded(
            child: taskState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(taskProvider.notifier).fetchTasks(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
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
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}
