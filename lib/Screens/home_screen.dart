
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';


import '../utils/generate_pdf.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> messages = [];

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  List<String> words = [];


  @override
  void initState() {
    super.initState();
    PdfService.generateShareAndPrintPdf();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _textController.text = _lastWords;
      words.add(_lastWords);
    });
  }

  // ---------- TEXT ----------
  void sendText(String text) {
    messages.add({"role": "user", "content": text});
    setState(() {});
  }

  // ---------- IMAGE ----------
  Future<void> pickImage() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print('image is picked');
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      print('base64encoded image is $base64Image');
      late final http.Response  response;
      try{
        print('api call started');
        response = await http.post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer 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',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "model": "nvidia/nemotron-nano-12b-v2-vl:free",
            "messages": [
              {
                "role": "user",
                "content": [

                  {
                    'type' : 'text',
                    'text': 'can you understand this image',
                  },{
                    'type' : 'image_url',
                    'imageUrl': {
                      'url': "data:image/jpeg;base64,$base64Image",
                    }
                  }
                ],
              }
            ]
          }),
        );
        print('api call ended');
      }catch(e){
        print('error in api call: $e');
      }
      print('response : ${response.statusCode}');

      if(response.statusCode == 200 || response.statusCode == 201){
        final data = jsonDecode(response.body);
        print('api called');

        String dataToPass = data['choices'][0]['message']['content'];
        messages.add({"role": "user", "content": dataToPass,});
        _textController.text = dataToPass;
        setState(() {});

      }

      // Send image to backend if needed
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    print(words);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Align(
                    alignment: msg["role"] == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg["role"] == "user"
                            ? Colors.amber
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg["content"]!),
                    ),
                  );
                },
              ),
            ),

            // INPUT BAR
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_speechToText.isNotListening ? Icons.stop : Icons.mic),
                  onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {

                    sendText(_textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
