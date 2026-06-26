//workout detail screen - view and edit a previously logged workout
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutId;
  final String date;

  const WorkoutDetailScreen({super.key, required this.workoutId, required this.date});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  //separate controller maps keyed by entry id so each row stays in sync
  final Map<String, TextEditingController> _setsControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _weightControllers = {};

  //updates each entry in firestore with the edited values
  Future<void> _saveChanges(List<QueryDocumentSnapshot> entries) async {
    for (final entry in entries) {
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(widget.workoutId)
          .collection('entries')
          .doc(entry.id)
          .update({
        'sets': int.tryParse(_setsControllers[entry.id]?.text ?? '') ?? 0,
        'reps': int.tryParse(_repsControllers[entry.id]?.text ?? '') ?? 0,
        'weight': double.tryParse(_weightControllers[entry.id]?.text ?? '') ?? 0,
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout updated!')),
      );
      Navigator.pop(context);
    }
  }

  //deletes the workout and all its entries from firestore
  Future<void> _deleteWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      //firestore doesn't auto-delete subcollections, so delete entries first
      final entriesSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(widget.workoutId)
          .collection('entries')
          .get();

      for (final entry in entriesSnapshot.docs) {
        await entry.reference.delete();
      }

      await FirebaseFirestore.instance.collection('workouts').doc(widget.workoutId).delete();

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout — ${widget.date}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteWorkout,
          ),
        ],
      ),
      //listen to real-time updates on the entries subcollection
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workouts')
            .doc(widget.workoutId)
            .collection('entries')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exercises in this workout.'));
          }

          final entries = snapshot.data!.docs;

          //initialize controllers only if they don't exist yet
          for (final entry in entries) {
            final data = entry.data() as Map<String, dynamic>;
            _setsControllers.putIfAbsent(entry.id, () => TextEditingController(text: '${data['sets'] ?? 0}'));
            _repsControllers.putIfAbsent(entry.id, () => TextEditingController(text: '${data['reps'] ?? 0}'));
            _weightControllers.putIfAbsent(entry.id, () => TextEditingController(text: '${data['weight'] ?? 0}'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final data = entry.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['exerciseName'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(data['category'] ?? '', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _setsControllers[entry.id],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Sets',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _repsControllers[entry.id],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Reps',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _weightControllers[entry.id],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Weight (lbs)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveChanges(entries),
                    child: const Text('Save Changes'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
