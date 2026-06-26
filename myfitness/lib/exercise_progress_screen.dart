//exercise progress screen - shows a weight chart and history for a single exercise
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ExerciseProgressScreen extends StatefulWidget {
  final String exerciseName;

  const ExerciseProgressScreen({super.key, required this.exerciseName});

  @override
  State<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  //default to showing last 30 days
  int _selectedDays = 30;

  final List<Map<String, dynamic>> _filters = [
    {'label': '1W', 'days': 7},
    {'label': '1M', 'days': 30},
    {'label': '3M', 'days': 90},
    {'label': '6M', 'days': 180},
    {'label': '1Y', 'days': 365},
  ];

  //loads all logged entries for this exercise across all workout sessions
  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final workouts = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    final List<Map<String, dynamic>> history = [];

    for (final workout in workouts.docs) {
      final data = workout.data();
      final date = (data['date'] as Timestamp).toDate();

      final entries = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workout.id)
          .collection('entries')
          .where('exerciseName', isEqualTo: widget.exerciseName)
          .get();

      for (final entry in entries.docs) {
        final entryData = entry.data();
        history.add({
          'date': date,
          'sets': entryData['sets'] ?? 0,
          'reps': entryData['reps'] ?? 0,
          'weight': (entryData['weight'] ?? 0).toDouble(),
        });
      }
    }

    history.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return history;
  }

  //filters history to only include entries within the selected time range
  List<Map<String, dynamic>> _filterByDays(List<Map<String, dynamic>> history) {
    final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
    return history.where((e) => (e['date'] as DateTime).isAfter(cutoff)).toList();
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No history found for this exercise.'),
            );
          }

          final filtered = _filterByDays(snapshot.data!);
          //map filtered entries to chart data points
          final spots = filtered.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value['weight'] as double);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //time range filter chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _filters.map((f) {
                    final selected = _selectedDays == f['days'];
                    return ChoiceChip(
                      label: Text(f['label']),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedDays = f['days']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Weight Over Time (lbs)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: filtered.isEmpty
                      ? const Center(child: Text('No data for this period.', style: TextStyle(color: Colors.grey)))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= filtered.length) return const SizedBox();
                                    return Text(
                                      _formatDate(filtered[index]['date'] as DateTime),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No entries in this time range.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            //show most recent entries first
                            final entry = filtered[filtered.length - 1 - index];
                            return ListTile(
                              title: Text(_formatDate(entry['date'] as DateTime)),
                              trailing: Text(
                                '${entry['sets']} sets × ${entry['reps']} reps @ ${entry['weight']} lbs',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
