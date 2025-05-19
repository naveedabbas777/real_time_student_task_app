import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import 'upload_students_dialog.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<User>? _students;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final students = await context.read<ApiService>().getStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _uploadStudents() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const UploadStudentsDialog(),
    );

    if (result == true) {
      _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students == null
              ? const Center(child: Text('Error loading students'))
              : _students!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No students yet'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _uploadStudents,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Students'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStudents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _students!.length,
                        itemBuilder: (context, index) {
                          final student = _students![index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(student.name),
                              subtitle: Text(student.email),
                              trailing: IconButton(
                                icon: const Icon(Icons.bar_chart),
                                onPressed: () async {
                                  try {
                                    final performance = await context
                                        .read<ApiService>()
                                        .getStudentPerformance(student.id);
                                    if (!mounted) return;
                                    // TODO: Show performance details in a dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Completion rate: ${performance['completionRate']}%',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadStudents,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
