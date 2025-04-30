import 'package:flutter/material.dart';
import 'package:project_exam/services/voice_service.dart';

class VoiceButton extends StatefulWidget {
  final Function(String) onResult;
  final VoiceService voiceService;

  const VoiceButton({
    super.key,
    required this.onResult,
    required this.voiceService,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        onPressed: () async {
          if (widget.voiceService.isListening) {
            await widget.voiceService.stopListening();
            _animationController.stop();
          } else {
            await widget.voiceService.startListening(widget.onResult);
            _animationController.repeat(reverse: true);
          }
          setState(() {});
        },
        backgroundColor: widget.voiceService.isListening ? Colors.red : Colors.blue,
        child: Icon(
          widget.voiceService.isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
      ),
    );
  }
} 