//exercise screen - shows the list of available exercises
//selectionMode is true when the user is picking an exercise for a workout
import 'package:flutter/material.dart';
import 'exercise_entry_screen.dart';

class ExerciseScreen extends StatelessWidget {
  final bool selectionMode;

  const ExerciseScreen({super.key, this.selectionMode = false});

  //built-in exercise library
  static const List<Map<String, String>> _exercises = [
    {'name': 'Squat', 'category': 'Legs'},
    {'name': 'Deadlift', 'category': 'Legs'},
    {'name': 'Bench Press', 'category': 'Chest'},
    {'name': 'Push Up', 'category': 'Chest'},
    {'name': 'Overhead Press', 'category': 'Shoulders'},
    {'name': 'Pull Up', 'category': 'Back'},
    {'name': 'Bent Over Row', 'category': 'Back'},
    {'name': 'Dumbbell Curl', 'category': 'Arms'},
    {'name': 'Tricep Dip', 'category': 'Arms'},
    {'name': 'Plank', 'category': 'Core'},
  ];

  //shows a dialog to create a custom exercise, then navigates to entry screen
  //screenContext is used to avoid context issues after the dialog is dismissed
  void _showCustomExerciseDialog(BuildContext screenContext) {
    final nameController = TextEditingController();
    String selectedCategory = 'Legs';
    final categories = ['Legs', 'Chest', 'Back', 'Shoulders', 'Arms', 'Core'];

    showDialog(
      context: screenContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Custom Exercise'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(context); //close dialog
                    if (selectionMode) {
                      //go to entry screen and pass result back to workout session
                      final result = await Navigator.push(
                        screenContext,
                        MaterialPageRoute(
                          builder: (context) => ExerciseEntryScreen(
                            name: name,
                            category: selectedCategory,
                          ),
                        ),
                      );
                      if (result != null && screenContext.mounted) {
                        Navigator.pop(screenContext, result);
                      }
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: ListView.builder(
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return ListTile(
            title: Text(exercise['name']!),
            subtitle: Text(exercise['category']!),
            trailing: selectionMode ? const Icon(Icons.chevron_right) : null,
            //tapping an exercise goes to the entry screen to fill in sets/reps/weight
            onTap: selectionMode
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseEntryScreen(
                          name: exercise['name']!,
                          category: exercise['category']!,
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      Navigator.pop(context, result);
                    }
                  }
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomExerciseDialog(context),
        icon: const Icon(Icons.edit),
        label: const Text('Custom Exercise'),
      ),
    );
  }
}
