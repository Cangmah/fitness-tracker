//workout session screen - where users log a new workout
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_screen.dart';

//holds the data for a single exercise entry in the session
class WorkoutEntry {
  final String name;
  final String category;
  final int sets;
  final int reps;
  final double weight;

  WorkoutEntry({
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    required this.weight,
  });
}

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  //list of exercises added to this session
  final List<WorkoutEntry> _entries = [];

  //opens exercise picker and adds the result to the session
  Future<void> _addExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseScreen(selectionMode: true)),
    );
    if (result != null) {
      setState(() {
        _entries.add(WorkoutEntry(
          name: result['name'],
          category: result['category'],
          sets: result['sets'] ?? 0,
          reps: result['reps'] ?? 0,
          weight: (result['weight'] ?? 0).toDouble(),
        ));
      });
    }
  }

  //saves the workout and all entries to firestore
  Future<void> _saveWorkout() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    //create the workout document first, then add each exercise as a subcollection
    final workoutRef = await FirebaseFirestore.instance.collection('workouts').add({
      'userId': user.uid,
      'date': Timestamp.now(),
      'notes': '',
    });

    for (final entry in _entries) {
      await workoutRef.collection('entries').add({
        'exerciseName': entry.name,
        'category': entry.category,
        'sets': entry.sets,
        'reps': entry.reps,
        'weight': entry.weight,
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          TextButton(
            onPressed: _addExercise,
            child: const Text('+ Add'),
          ),
          TextButton(
            onPressed: _saveWorkout,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      //show prompt if no exercises added yet
      body: _entries.isEmpty
          ? const Center(
              child: Text(
                'No exercises added yet.\nTap "+ Add" to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(entry.category),
                    trailing: Text(
                      '${entry.sets} sets × ${entry.reps} reps\n${entry.weight} lbs',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
