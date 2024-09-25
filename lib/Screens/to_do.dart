import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/Widgets/todo_tiles.dart';

import '../Functions/show_add_task_dialog_func.dart';
import '../Provider/task_provider.dart';
import 'auth_screen.dart';

class TodoScreen extends StatefulWidget {
  VoidCallback setState;
  TodoScreen({super.key, required this.setState});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? profilePicUrl;
  String? displayName;
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          profilePicUrl = userDoc['profilePic']; // User profile picture URL
          displayName = userDoc['name']; // User display name
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to AuthScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _logoutUser(); // Logout user
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider =
        Provider.of<TaskProvider>(context, listen: false).savedTasks;
    int totalTasks =
        Provider.of<TaskProvider>(context, listen: false).getTotalTaskCount();

    return Scaffold(
      appBar: AppBar(
        leading: null,
        toolbarHeight: 105,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profilePicUrl != null
                        ? NetworkImage(profilePicUrl!)
                        : AssetImage('assets/default_profile.png')
                            as ImageProvider, // Default image in case profilePicUrl is null
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName ??
                            'User', // Use the name fetched from Firestore
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Consumer<TaskProvider>(
                        builder: (BuildContext context, TaskProvider value,
                            Widget? child) {
                          return Text(
                            'You have ${totalTasks} tasks today',
                            style: TextStyle(color: Colors.grey, fontSize: 17),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFDAE0E2),
                    width: 1.0,
                  ),
                ),
                child: MaterialButton(
                  shape: const CircleBorder(),
                  color: Colors.red,
                  onPressed:
                      _showLogoutDialog, // Show logout confirmation dialog
                  child: const Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: Colors.blue,
        onPressed: () {
          ShowAddTaskDialogFunc(onTaskAdded: () {
            setState(() {});
          }).showAddTaskDialog(context, taskNameController,
              taskDescriptionController, startDate, endDate);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30),
              child: Text(
                'Tasks',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                mainAxisSpacing: 20.0, // Spacing between rows
                crossAxisSpacing: 20.0, // Spacing between columns
                childAspectRatio: 0.8, // Aspect ratio of each item
              ),
              itemCount: taskProvider.length,
              itemBuilder: (context, index) {
                return TodoTiles(
                  newTask: taskProvider[index],
                  callback: () {
                    setState(() {});
                  },
                );
              },
              padding: const EdgeInsets.all(8.0),
            ),
          ],
        ),
      ),
    );
  }
}
