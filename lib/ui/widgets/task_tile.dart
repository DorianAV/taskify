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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.status == TaskStatus.completed,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
            color: task.status == TaskStatus.completed ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  task.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
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
        trailing: PopupMenuButton(
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
    );
  }
}
