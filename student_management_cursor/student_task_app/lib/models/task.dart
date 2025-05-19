import 'user.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final User assignedTo;
  final User createdBy;
  final String status;
  final DateTime dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.createdBy,
    required this.status,
    required this.dueDate,
    this.completedAt,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedTo: User.fromJson(json['assigned_to'] ?? {}),
      createdBy: User.fromJson(json['created_by'] ?? {}),
      status: json['status'] ?? 'pending',
      dueDate:
          json['due_date'] != null
              ? DateTime.parse(json['due_date'])
              : DateTime.now(),
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'assigned_to': assignedTo.id,
      'status': status,
      'due_date': dueDate.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);
}
