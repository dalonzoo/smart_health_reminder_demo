import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class IntentClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;
  late Map<String, int> _vocabulary;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the TFLite model
      final interpreterOptions = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        'assets/models/intent_classifier.tflite',
        options: interpreterOptions,
      );

      // Load labels
      final labelsData = await rootBundle.loadString('assets/models/intent_labels.txt');
      _labels = labelsData.split('\n');

      // Load vocabulary (map words to their indices)
      final vocabularyData = await rootBundle.loadString('assets/models/vocabulary.txt');
      _vocabulary = _loadVocabulary(vocabularyData);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing intent classifier: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> classifyIntent(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Preprocess text (convert to lowercase, remove punctuation, etc.)
    final processedText = _preprocessText(text);

    // Convert text to input tensor
    final input = _textToInputTensor(processedText);

    // Output tensor
    final output = List<List<double>>.filled(
      1,
      List<double>.filled(_labels.length, 0),
    );

    // Run inference
    _interpreter.run(input, output);

    // Convert output to map of intent -> confidence
    final Map<String, double> results = {};
    for (int i = 0; i < _labels.length; i++) {
      results[_labels[i]] = output[0][i];


    }
    return results;
  }

  String _preprocessText(String text) {
    // Convert to lowercase
    String processed = text.toLowerCase();

    // Remove punctuation
    processed = processed.replaceAll(RegExp(r'[^\w\s]'), '');

    return processed;
  }

  Map<String, int> _loadVocabulary(String data) {
    final Map<String, int> vocabulary = {};
    final lines = data.split('\n');
    for (var line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        vocabulary[parts[0]] = int.parse(parts[1]);
      }
    }

    return vocabulary;
  }

  List<List<int>> _textToInputTensor(String text) {
    // Split into words
    final words = text.split(' ');
    // Convert to word indices using the vocabulary
    final wordIndices = words.map((word) {
      print(word);
      return _vocabulary[word] ?? 0; // Use 0 if the word is not in the vocabulary
    }).toList();

    // Pad or truncate to fixed length (e.g., 50 words)
    const maxLength = 50;
    if (wordIndices.length > maxLength) {
      wordIndices.length = maxLength;
    } else {
      while (wordIndices.length < maxLength) {
        wordIndices.add(0); // Padding
      }
    }

    return [wordIndices];
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
    }
  }
}
