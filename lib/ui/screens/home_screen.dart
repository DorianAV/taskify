import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Taskify/ui/screens/calendar_screen.dart';
import '../../data/models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_dialog.dart';
import '../widgets/statistics_widget.dart';
import '../widgets/empty_state_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    // Fetch tasks when screen loads
    Future.microtask(() => ref.read(taskProvider.notifier).fetchTasks());
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final tasks = taskState.filteredTasks;
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(taskProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Taskify',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                ref.read(taskProvider.notifier).setSearchQuery(value);
              },
            ),
          ),
          
          // Statistics Widget
          const StatisticsWidget(),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: TaskFilter.values.map((filter) {
                final isSelected = taskState.filter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      _getFilterLabel(filter),
                      style: TextStyle(
                        color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black87),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(taskProvider.notifier).setFilter(filter);
                    },
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
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
                    ? EmptyStateWidget(
                        message: taskState.searchQuery.isNotEmpty 
                            ? 'No se encontraron resultados' 
                            : 'No tienes tareas pendientes',
                        subMessage: taskState.searchQuery.isNotEmpty
                            ? 'Intenta con otra búsqueda'
                            : '¡Agrega una nueva tarea para comenzar!',
                        icon: taskState.searchQuery.isNotEmpty ? Icons.search_off : Icons.task_alt,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(taskProvider.notifier).fetchTasks(),
                        child: ListView.builder(
                          key: _listKey,
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 300 + (index * 50)), // Staggered animation
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: TaskTile(
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
                                onStatusChange: () => _showStatusChangeDialog(task),
                              ),
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
        label: const Text('Nueva Tarea'),
      ),
    );
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'Todas';
      case TaskFilter.pending:
        return 'Pendientes';
      case TaskFilter.inProgress:
        return 'En Progreso';
      case TaskFilter.completed:
        return 'Completadas';
    }
  }

  void _showTaskDialog([Task? task]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );

    if (result != null) {
      if (task == null) {
        ref.read(taskProvider.notifier).addTask(
          result['title']!,
          result['description']!,
          result['status'] as TaskStatus,
          result['date'],
          result['time'],
          result['priority'] as TaskPriority,
          result['color']!,
        );
      } else {
        ref.read(taskProvider.notifier).updateTask(
              task.copyWith(
                title: result['title'],
                description: result['description'],
                status: result['status'] as TaskStatus,
                date: result['date'],
                time: result['time'],
                priority: result['priority'] as TaskPriority,
                color: result['color'],
              ),
            );
      }
    }
  }

  void _showStatusChangeDialog(Task task) async {
    final newStatus = await showDialog<TaskStatus>(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (newStatus != null && newStatus != task.status) {
      ref.read(taskProvider.notifier).updateTask(task.copyWith(status: newStatus));
    }
  }
}
