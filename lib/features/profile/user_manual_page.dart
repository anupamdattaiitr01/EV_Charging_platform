import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserManualPage extends StatefulWidget {
  const UserManualPage({super.key});

  @override
  State<UserManualPage> createState() => _UserManualPageState();
}

class _UserManualPageState extends State<UserManualPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController (Modern syntax for webview_flutter ^4.0.0)
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          // --- NEW: Add this error handler ---
          onWebResourceError: (WebResourceError error) {
            print("WebView Error: ${error.description}"); // Prints the exact cause to your console
            if (mounted) {
              setState(() {
                _isLoading = false; // Kills the spinner even if the page fails
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://coolors.co/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("User Manual", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF161B22),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Forces the WebView to take up the full screen, ensuring it renders
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),

          // The loading spinner
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            ),
        ],
      ),
    );
  }
}