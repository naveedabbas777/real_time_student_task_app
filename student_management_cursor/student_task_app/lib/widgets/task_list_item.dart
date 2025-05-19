import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final Function(String) onStatusChanged;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned to: ${task.assignedTo.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${DateFormat('MMM d, y').format(task.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: task.isOverdue
                                ? Colors.red
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                if (!task.isCompleted)
                  TextButton(
                    onPressed: () => onStatusChanged('completed'),
                    child: const Text('Mark Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    late final Color backgroundColor;
    late final Color textColor;
    late final String text;

    if (task.isCompleted) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      text = 'Completed';
    } else if (task.isOverdue) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      text = 'Overdue';
    } else {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
