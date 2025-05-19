import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../services/api_service.dart';

class UploadStudentsDialog extends StatefulWidget {
  const UploadStudentsDialog({super.key});

  @override
  State<UploadStudentsDialog> createState() => _UploadStudentsDialogState();
}

class _UploadStudentsDialogState extends State<UploadStudentsDialog> {
  bool _isLoading = false;
  String? _fileName;
  List<Map<String, dynamic>>? _students;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        final bytes = result.files.first.bytes;
        if (bytes == null) {
          throw 'Could not read file';
        }

        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables[excel.tables.keys.first];
        if (sheet == null) {
          throw 'No sheet found in Excel file';
        }

        final students = <Map<String, dynamic>>[];
        var isHeader = true;

        for (var row in sheet.rows) {
          if (isHeader) {
            isHeader = false;
            continue;
          }

          if (row.length < 2) continue;

          students.add({
            'name': row[0]?.value?.toString() ?? '',
            'email': row[1]?.value?.toString() ?? '',
            'password': row.length > 2 ? row[2]?.value?.toString() : null,
          });
        }

        setState(() {
          _fileName = result.files.first.name;
          _students = students;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _uploadStudents() async {
    if (_students == null || _students!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await context.read<ApiService>().uploadStudents(_students!);

      if (!mounted) return;
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully added ${result['results']['success'].length} students',
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Students',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_fileName != null) ...[
              Text(
                'Selected file: $_fileName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Found ${_students?.length ?? 0} students',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Excel File'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      _isLoading || _students == null ? null : _uploadStudents,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
