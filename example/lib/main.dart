import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_device_ai/on_device_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _onDeviceAiPlugin = OnDeviceAi();
  final _textController = TextEditingController(
    text: 'This SDK is absolutely amazing!',
  );
  String _outputText = 'Waiting for input...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    setState(() => _isLoading = true);
    try {
      // iOS uses built in NLP for this demo, Android uses the downloaded TFLite file
      final modelName = Platform.isIOS
          ? 'built_in_sentiment'
          : 'sentiment_analysis.tflite';
      await _onDeviceAiPlugin.loadModel(modelName, config: ModelConfig());
      setState(() => _outputText = 'Model ($modelName) loaded successfully.');
    } catch (e) {
      setState(() => _outputText = 'Failed to load model: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runTextInference() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _outputText = 'Running inference...';
    });

    try {
      final result = await _onDeviceAiPlugin.runText(_textController.text);
      setState(() {
        _outputText =
            'Sentiment: ${result.output}\n'
            'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%\n'
            'Time: ${result.inferenceTimeMs}ms';
      });
    } catch (e) {
      setState(() => _outputText = 'Inference failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Real AI Inference Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Status: ${_isLoading ? "Processing..." : "Idle"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text to analyze sentiment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isLoading ? null : _runTextInference,
                child: const Text('Analyze Sentiment'),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey[200]!),
                ),
                child: Text(_outputText, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
