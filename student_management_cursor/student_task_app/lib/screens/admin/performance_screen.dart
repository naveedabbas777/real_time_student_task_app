import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  List<Map<String, dynamic>>? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await context.read<ApiService>().getTasks();
      final stats = await context.read<ApiService>().getStudents();

      // Process stats here
      // This is a simplified version. In a real app, you'd want to use the
      // actual stats endpoint we created in the backend
      setState(() {
        _stats = stats.map((student) {
          final studentTasks = response
              .where(
                (task) => task.assignedTo.id == student.id,
              )
              .toList();

          final completed =
              studentTasks.where((task) => task.isCompleted).length;

          return {
            'name': student.name,
            'email': student.email,
            'totalTasks': studentTasks.length,
            'completedTasks': completed,
            'completionRate': studentTasks.isEmpty
                ? 0.0
                : (completed / studentTasks.length) * 100,
          };
        }).toList();

        _stats?.sort(
            (a, b) => b['completionRate'].compareTo(a['completionRate']));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('Error loading statistics'))
              : _stats!.isEmpty
                  ? const Center(child: Text('No data available'))
                  : RefreshIndicator(
                      onRefresh: _loadStats,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Student Performance',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 100,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value < 0 ||
                                            value >= _stats!.length) {
                                          return const SizedBox();
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            _stats![value.toInt()]['name']
                                                .toString()
                                                .split(' ')[0],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}%',
                                          style: const TextStyle(fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  _stats!.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: _stats![index]['completionRate'],
                                        color: Theme.of(context).primaryColor,
                                        width: 20,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Detailed Statistics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            _stats!.length,
                            (index) => Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _stats![index]['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(_stats![index]['email']),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: _stats![index]['completionRate'] /
                                          100,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Completed: ${_stats![index]['completedTasks']}/${_stats![index]['totalTasks']} tasks (${_stats![index]['completionRate'].toStringAsFixed(1)}%)',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
