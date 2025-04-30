import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_exam/providers/task_provider.dart';
import 'package:project_exam/services/voice_service.dart';
import 'package:project_exam/widgets/task_list.dart';
import 'package:project_exam/widgets/voice_button.dart';
import 'package:project_exam/models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceService _voiceService;
  bool _isInitialized = false;
  final TextEditingController _textController = TextEditingController();
  String _currentTranscription = '';

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    _voiceService = context.read<VoiceService>();
    _isInitialized = await _voiceService.initialize();
    setState(() {});
  }

  void _handleVoiceCommand(String command) {
    setState(() {
      _currentTranscription = command;
      _textController.text = command;
    });
    final taskProvider = context.read<TaskProvider>();
    final lowerCommand = command.toLowerCase();

    if (lowerCommand.startsWith('add')) {
      final taskTitle = command.substring(3).trim();
      if (taskTitle.isNotEmpty) {
        taskProvider.addTask(taskTitle);
        _voiceService.speak('Task added: $taskTitle');
        setState(() {
          _currentTranscription = '';
          _textController.clear();
        });
      }
    } else if (lowerCommand.startsWith('complete')) {
      final taskTitle = command.substring(8).trim();
      final task = taskProvider.tasks.firstWhere(
        (t) => t.title.toLowerCase().contains(taskTitle.toLowerCase()),
        orElse: () => Task(
          id: '',
          title: '',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );
      if (task.id.isNotEmpty) {
        taskProvider.toggleTaskCompletion(task.id);
        _voiceService.speak('Task completed: ${task.title}');
        setState(() {
          _currentTranscription = '';
          _textController.clear();
        });
      }
    } else if (lowerCommand.startsWith('delete')) {
      final taskTitle = command.substring(6).trim();
      final task = taskProvider.tasks.firstWhere(
        (t) => t.title.toLowerCase().contains(taskTitle.toLowerCase()),
        orElse: () => Task(
          id: '',
          title: '',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );
      if (task.id.isNotEmpty) {
        taskProvider.deleteTask(task.id);
        _voiceService.speak('Task deleted: ${task.title}');
        setState(() {
          _currentTranscription = '';
          _textController.clear();
        });
      }
    } else {
      _voiceService.speak('I didn\'t understand that command. Please try again.');
    }
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<TaskProvider>().addTask(text);
      _voiceService.speak('Task added: $text');
      setState(() {
        _currentTranscription = '';
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice-Driven To-Do'),
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                child: const TaskList(),
              ),
              if (!_isInitialized)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Initializing voice service...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              // Leave out the bar here!
            ],
          ),
          // Bottom bar with text field and submit button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), // leave space for FAB
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'What are you working on?',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isInitialized
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0), // move FAB up above the bar
              child: VoiceButton(
                onResult: _handleVoiceCommand,
                voiceService: _voiceService,
              ),
            )
          : null,
    );
  }
} 