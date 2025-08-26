import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/app_links.dart';

class MentorWebViewScreen extends StatefulWidget {
  const MentorWebViewScreen({super.key});
  @override
  State<MentorWebViewScreen> createState() => _MentorWebViewScreenState();
}

class _MentorWebViewScreenState extends State<MentorWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p),
      ))
      ..loadRequest(Uri.parse(mentorChatUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return const Scaffold(
        body: Center(child: Text('In-app view not available on this platform.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(mentorName)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_progress < 100) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
