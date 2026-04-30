import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _imagePicker = ImagePicker();
  
  String _outputText = 'Waiting for input...';
  bool _isLoading = false;
  
  // Track active model type to prevent unnecessary reloads
  String _activeModelType = '';

  @override
  void initState() {
    super.initState();
    // Default to text model on startup
    _loadTextModel();
  }

  Future<void> _loadTextModel() async {
    if (_activeModelType == 'text') return;
    setState(() => _isLoading = true);
    try {
      final modelName = Platform.isIOS
          ? 'built_in_sentiment'
          : 'sentiment_analysis.tflite';
      await _onDeviceAiPlugin.loadModel(modelName, config: ModelConfig());
      _activeModelType = 'text';
      setState(() => _outputText = 'Text Model loaded successfully.');
    } catch (e) {
      setState(() => _outputText = 'Failed to load text model: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadImageModel() async {
    if (_activeModelType == 'image') return;
    setState(() => _isLoading = true);
    try {
      final modelName = Platform.isIOS
          ? 'built_in_vision'
          : 'mobilenet_v1_1.0_224_quant.tflite';
      await _onDeviceAiPlugin.loadModel(modelName, config: ModelConfig());
      _activeModelType = 'image';
    } catch (e) {
      setState(() => _outputText = 'Failed to load image model: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runTextInference() async {
    if (_textController.text.isEmpty) return;
    
    await _loadTextModel();
    
    setState(() {
      _isLoading = true;
      _outputText = 'Running text inference...';
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

  Future<void> _pickAndAnalyzeImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) return;

    await _loadImageModel();

    setState(() {
      _isLoading = true;
      _outputText = 'Analyzing image...';
    });

    try {
      final bytes = await image.readAsBytes();
      final result = await _onDeviceAiPlugin.runImage(bytes);

      setState(() {
        _outputText =
            'Found: ${result.output}\n'
            'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%\n'
            'Time: ${result.inferenceTimeMs}ms';
      });
    } catch (e) {
      setState(() => _outputText = 'Image analysis failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Multimodal AI SDK Demo')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Status: ${_isLoading ? "Processing..." : "Idle"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Text Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text to analyze sentiment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _runTextInference,
                child: const Text('Analyze Sentiment'),
              ),
              
              const Divider(height: 32),

              const Text(
                'Image Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndAnalyzeImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image & Analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'AI Output:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
