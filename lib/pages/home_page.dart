import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String quote = "Click the button to get inspired";
  String author = '';
  bool isLoading = false;

  Timer? _timer;
  int _start = 10;

  @override
  void initState() {
    super.initState();

    fetchQuote();

    startTimer();
  }

  void startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        fetchQuote();

        setState(() {
          _start = 10;
        });

      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/quotes/random"),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          quote = data['quote'];
          author = data['author'];
          isLoading = false;
        });
      } else {
        setState(() {
          quote = "Failed to load quote";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        quote = "Error: Check your internet connection";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Daily inspiration"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                children: [
                  isLoading
                      ? Center(
                          child: const CircularProgressIndicator(
                          color: Colors.deepPurple,
                          )
                        )
                      : Center(
                        child: Column(
                            children: [
                              Text(
                                quote,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                author,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: fetchQuote,
              icon: const Icon(Icons.refresh),
              label: const Text("New Quote"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
