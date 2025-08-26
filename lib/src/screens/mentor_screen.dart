import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_links.dart';
import '../core/net.dart';
import 'mentor_webview.dart';

Future<void> openMentor(BuildContext context) async {
  final uri = Uri.parse(mentorChatUrl);

  // capture UI handles BEFORE awaits
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final online = await hasNetwork();
  if (!online) {
    messenger.showSnackBar(
      SnackBar(
        content: const Text('You appear to be offline.'),
        action: SnackBarAction(label: 'Retry', onPressed: () => openMentor(context)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final supportsInApp =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  if (supportsInApp) {
    navigator.push(MaterialPageRoute(
      builder: (_) => const MentorWebViewScreen(),
    ));
    return;
  }

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Could not open UMC.'),
        action: SnackBarAction(
          label: 'Open in Browser',
          onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
