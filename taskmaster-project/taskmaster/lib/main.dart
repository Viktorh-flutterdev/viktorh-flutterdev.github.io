import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TaskMasterApp());
}

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMaster',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E90FF), // Blue from floral theme
        scaffoldBackgroundColor: const Color(0xFFF4F4F4), // Light gray
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFFF4500), // Red-orange accent
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF333333)), // Black text
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}

class Task {
  final String title;
  final String description;

  Task({required this.title, required this.description});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'],
      );
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      setState(() {
        tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString =
        jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksString);
  }

  void _addTask() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(
          title: _titleController.text,
          description: _descriptionController.text,
        ));
        _titleController.clear();
        _descriptionController.clear();
      });
      _saveTasks();
      Navigator.of(context).pop();
    }
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMaster'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Add one!'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(tasks[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tasks[index].description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFFF4500)),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
