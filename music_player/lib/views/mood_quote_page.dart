import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini API package
import 'home.dart'; // Transition to Home after quote

const String apiKey = 'AIzaSyDSbzNCKaBRGNK6b8DryOfbchfiEm8LGj4';

class MoodQuotePage extends StatefulWidget {
  final String mood;
  final List<String> songs;

  const MoodQuotePage({super.key, required this.mood, required this.songs});

  @override
  _MoodQuotePageState createState() => _MoodQuotePageState();
}

class _MoodQuotePageState extends State<MoodQuotePage>
    with TickerProviderStateMixin {
  String quote = "Fetching your comforting quote...";
  bool isLoading = true; // Add loading state
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late AnimationController _transitionController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation for fade effect
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Initialize animation for transition scale effect
    _transitionController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    fetchQuote();
  }

  Future<void> fetchQuote() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final prompt = "Provide a comforting quote for someone feeling ${widget.mood.toLowerCase()}.";
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        setState(() {
          quote = response.text!;
          isLoading = false; // Stop loading after the quote is fetched
        });

        // Trigger animated transition to home.dart after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          _transitionController.forward();
          Get.off(() => Home(
                selectedMood: widget.mood,
                playlistSongs: widget.songs,
              ),
              transition: Transition.zoom);
        });
      } else {
        setState(() {
          quote = "Sometimes words are not enough, but you are strong.";
          isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      setState(() {
        quote = "Something went wrong, but you're amazing as always!";
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Here's something for you:",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  quote,
                  style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Conditional loading indicator
                if (isLoading)
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
