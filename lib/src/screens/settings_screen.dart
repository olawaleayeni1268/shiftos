import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.color_lens_outlined),
          title: Text('Theme'),
          subtitle: Text('Follows system (Light/Dark)'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('About ShiftOS'),
          subtitle: Text('MVP preview'),
        ),
      ],
    );
  }
}
