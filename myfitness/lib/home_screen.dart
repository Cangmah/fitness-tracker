//home screen - main shell that holds the bottom navigation and three tabs
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'workout_session_screen.dart';
import 'workout_detail_screen.dart';
import 'progress_screen.dart';

//manages which tab is currently active and renders the bottom nav bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    _LogTab(),
    ProgressScreen(),
  ];

  final List<String> _titles = ['myFitness', 'Log Workout', 'Progress'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          //only show logout on the home tab
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
            ),
        ],
      ),
      body: _tabs[_currentIndex],
      //log tab launches workout session as a new screen instead of switching tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkoutSessionScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
        ],
      ),
    );
  }
}

//home tab - shows a welcome message and the user's previous workout history
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        //fetch the user's name from firestore and show a welcome message
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
          builder: (context, snapshot) {
            final name = (snapshot.data?.data() as Map<String, dynamic>?)?['name'] ?? '';
            if (name.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Welcome, $name! Let's kill it today!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Previous Workouts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        //stream builder keeps the list updated in real time
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('workouts')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No workouts logged yet.\nTap Log to start.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              //sort workouts by most recent first on the client side
              final workouts = snapshot.data!.docs
                ..sort((a, b) {
                  final aDate = (a.data() as Map<String, dynamic>)['date'] as Timestamp;
                  final bDate = (b.data() as Map<String, dynamic>)['date'] as Timestamp;
                  return bDate.compareTo(aDate);
                });

              return ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final doc = workouts[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final date = data['date'] as Timestamp;

                  return ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text('Workout — ${_formatDate(date)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailScreen(
                            workoutId: doc.id,
                            date: _formatDate(date),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

//placeholder tab - log button opens workout session as a full screen instead
class _LogTab extends StatelessWidget {
  const _LogTab();

  @override
  Widget build(BuildContext context) => const SizedBox();
}
