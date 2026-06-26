//exercise entry screen - user fills in sets, reps, and weight for a chosen exercise
import 'package:flutter/material.dart';

class ExerciseEntryScreen extends StatefulWidget {
  final String name;
  final String category;

  const ExerciseEntryScreen({super.key, required this.name, required this.category});

  @override
  State<ExerciseEntryScreen> createState() => _ExerciseEntryScreenState();
}

class _ExerciseEntryScreenState extends State<ExerciseEntryScreen> {
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  //pops back with the exercise data so workout session can add it to the list
  void _save() {
    Navigator.pop(context, {
      'name': widget.name,
      'category': widget.category,
      'sets': int.tryParse(_setsController.text.trim()) ?? 0,
      'reps': int.tryParse(_repsController.text.trim()) ?? 0,
      'weight': double.tryParse(_weightController.text.trim()) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (lbs)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Add to Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
