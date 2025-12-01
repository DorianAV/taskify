import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onStatusChange;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onStatusChange,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.redAccent;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.low:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskColor = task.getParsedColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Color Strip
                  Container(
                    width: 6,
                    color: taskColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: task.status == TaskStatus.completed,
                                  onChanged: (_) => onToggle(),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  activeColor: taskColor,
                                  side: BorderSide(
                                    color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title and Description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                                        color: task.status == TaskStatus.completed 
                                            ? (isDark ? Colors.grey[600] : Colors.grey) 
                                            : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                    if (task.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          task.description,
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            fontSize: 13,
                                            decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Menu
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: PopupMenuButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.more_vert, color: isDark ? Colors.grey[400] : Colors.grey[400]),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'status',
                                      child: Row(
                                        children: [Icon(Icons.swap_horiz, size: 20), SizedBox(width: 8), Text('Cambiar Estado')],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Editar')],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'status') onStatusChange();
                                    if (value == 'edit') onEdit();
                                    if (value == 'delete') onDelete();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Metadata Row
                          Row(
                            children: [
                              // Priority Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority).withAlpha(26),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _getPriorityColor(task.priority).withAlpha(51)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.flag, size: 12, color: _getPriorityColor(task.priority)),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.getPriorityLabel(),
                                      style: TextStyle(
                                        color: _getPriorityColor(task.priority),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Date/Time
                              if (task.date != null) ...[
                                Icon(Icons.calendar_today, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  task.date!,
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (task.time != null) ...[
                                Icon(Icons.access_time, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  task.time!,
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                                ),
                              ],
                              const Spacer(),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status).withAlpha(26),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.getStatusLabel().toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(task.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
