// lib/screens/voice_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_reminder_demo/screens/posture_check_screen.dart';
import 'package:smart_health_reminder_demo/screens/water_tracker_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/gamification_provider.dart';
import '../providers/health_provider.dart';
import '../providers/reminder_provider.dart';
import '../services/nlp_service.dart';
import 'add_reminder_screen.dart';
import 'exercise_tracker_screen.dart';
import 'meditation_tracker_screen.dart';


class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({Key? key}) : super(key: key);

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  String _lastWords = '';
  String _responseText = '';
  bool _isProcessing = false;
  List<Map<String, dynamic>> _conversationHistory = [];

  late NLPService _nlpService;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize NLP service with providers
    _nlpService = NLPService(
      healthProvider: Provider.of<HealthProvider>(context),
      reminderProvider: Provider.of<ReminderProvider>(context),
      gamificationProvider: Provider.of<GamificationProvider>(context),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Initialize speech recognition
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
      },
    );

    if (!available) {
      // Handle speech recognition not available
    }
  }

  // Initialize text-to-speech
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Start listening for speech input
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _lastWords = '';
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _textController.text = _lastWords;
            });
          },
        );
      }
    }
  }

  // Stop listening for speech input
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  // Process the user input through NLP
  Future<void> _processInput() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _conversationHistory.add({
        'isUser': true,
        'text': input,
      });
    });

    // Process with NLP service
    final response = await _nlpService.processInput(input);

    setState(() {
      _responseText = response.message;
      _conversationHistory.add({
        'isUser': false,
        'text': response.message,
      });
      _isProcessing = false;
    });

    // Speak the response
    await _flutterTts.speak(response.message);

    // Handle different action types
    _handleNLPResponse(response);

    // Clear the input field
    _textController.clear();
  }

  // Handle the NLP response based on action type
  void _handleNLPResponse(NLPResponse response) {
    switch (response.actionType) {
      case NLPActionType.createReminder:
      // Navigate to add reminder screen with pre-filled data
        if (response.data != null) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddReminderScreen(
                  initialType: response.data!['type'] as int,
                  initialFrequency: response.data!['frequency'] as int,
                  initialTimeString: response.data!['time'] as String?,
                ),
              ),
            );
          });
        }
        break;

      case NLPActionType.startMeditation:
      // Navigate to meditation screen
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeditationTrackerScreen()),
          );
        });
        break;

      case NLPActionType.checkPosture:
      // Navigate to posture check screen
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostureCheckScreen()),
          );
        });
        break;

      case NLPActionType.addWaterIntake:
      case NLPActionType.queryWaterIntake:
      // Optionally navigate to water tracker screen
        if (response.actionType == NLPActionType.addWaterIntake) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WaterTrackerScreen()),
            );
          });
        }
        break;

      case NLPActionType.addSteps:
      case NLPActionType.querySteps:
      // Optionally navigate to exercise tracker screen
        if (response.actionType == NLPActionType.addSteps) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExerciseTrackerScreen()),
            );
          });
        }
        break;

      default:
      // No specific navigation needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: Column(
        children: [
          // Conversation history
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _conversationHistory.length,
              itemBuilder: (context, index) {
                final item = _conversationHistory[index];
                final isUser = item['isUser'] as bool;
                final text = item['text'] as String;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isUser ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice input button
                IconButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),

                // Text input field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Listening...'
                          : 'Type or speak your command...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    onSubmitted: (_) => _processInput(),
                  ),
                ),

                // Send button
                IconButton(
                  onPressed: _isProcessing ? null : _processInput,
                  icon: _isProcessing
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}