//progress screen - shows a list of unique exercises the user has logged
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_progress_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  //fetches all workout entries and returns a unique list of exercises
  Future<List<Map<String, dynamic>>> _loadExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final workouts = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    //use a map to deduplicate exercises by name
    final Map<String, String> exerciseMap = {};

    for (final workout in workouts.docs) {
      final entries = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workout.id)
          .collection('entries')
          .get();

      for (final entry in entries.docs) {
        final data = entry.data();
        final name = data['exerciseName'] as String? ?? '';
        final category = data['category'] as String? ?? '';
        if (name.isNotEmpty) {
          exerciseMap[name] = category;
        }
      }
    }

    return exerciseMap.entries
        .map((e) => {'name': e.key, 'category': e.value})
        .toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No exercises logged yet.\nStart a workout to track progress.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final exercises = snapshot.data!;

          //each exercise taps through to the chart and history screen
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                leading: const Icon(Icons.show_chart),
                title: Text(exercise['name']),
                subtitle: Text(exercise['category']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseProgressScreen(
                        exerciseName: exercise['name'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
  }
}
