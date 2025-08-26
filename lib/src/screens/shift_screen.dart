import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ShiftTab extends StatefulWidget {
  const ShiftTab({Key? key}) : super(key: key);

  @override
  State<ShiftTab> createState() => _ShiftTabState();
}

class _ShiftTabState extends State<ShiftTab> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    // const list -> silences prefer_const_declarations
    final steps = const [
      _Block(title: 'Invocation', icon: Icons.self_improvement_outlined, text: 'I and the Father are One…'),
      _Block(title: 'Decree', icon: Icons.record_voice_over_outlined, text: 'By my I AM Authority, I command…'),
      _Block(title: 'Visualization', icon: Icons.visibility_outlined, text: 'See it already done.'),
      _Block(title: 'Micro-Action', icon: Icons.bolt_outlined, text: 'One bold step today.'),
      _Block(title: 'Seal', icon: Icons.verified_outlined, text: 'It is written. It is done.'),
    ];

    final pct = ((_step + 1) / steps.length).clamp(0.0, 1.0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(child: LinearProgressIndicator(value: pct, minHeight: 6)),
              const SizedBox(width: 12),
              Text('${((_step + 1) * 100 ~/ steps.length)}%'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: steps.length,
            itemBuilder: (ctx, i) {
              final active = i == _step;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: active ? 1.0 : 0.6,
                child: steps[i],
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              icon: Icon(_step < steps.length - 1 ? Icons.arrow_forward : Icons.check_circle_outline),
              label: Text(_step < steps.length - 1 ? 'Next' : 'IT IS DONE'),
              onPressed: () async {
                if (_step < steps.length - 1) {
                  setState(() => _step++);
                  return;
                }

                // capture messenger before await (no async-gap context)
                final messenger = ScaffoldMessenger.of(context);

                final win = await _promptForWin(context);
                if (!mounted) return;
                await context.read<AppState>().completeShift(win: win);
                messenger.showSnackBar(const SnackBar(content: Text('Shift locked in ✨')));
                setState(() => _step = 0);
              },
            ),
          ),
        )
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.icon, required this.text, Key? key}) : super(key: key);
  final String title; final IconData icon; final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ]),
          ),
        ]),
      ),
    );
  }
}

Future<String?> _promptForWin(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Win (optional)'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'e.g., ₦10k, New client, Synchronicity'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Skip')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
      ],
    ),
  );
}
