import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.onStartShift,
    required this.onAddWin,
  });

  final VoidCallback onStartShift;
  final VoidCallback onAddWin;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gradient hero
        Container(
          decoration: BoxDecoration(
            gradient: Deco.heroGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: Deco.glow,
          ),
          padding: const EdgeInsets.all(20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Daily Shift",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              SizedBox(height: 6),
              Text(
                "Breathe • Speak • See • Act • Seal",
                style: TextStyle(color: Colors.black87),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(text: 'Clarity'),
                  _Chip(text: 'Calm'),
                  _Chip(text: 'Courage'),
                  _Chip(text: 'Cashflow'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Streak + last win card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Chip(
                  avatar: Icon(Icons.local_fire_department_outlined, size: 18),
                  label: Text('Day'),
                ),
                const SizedBox(width: 8),
                Text('${app.streak}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Win', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        app.lastWin ?? 'No wins logged yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (app.didShiftToday)
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Shift complete for today. See you tomorrow ✨'),
            ),
          ),

        const SizedBox(height: 8),

        // Quick actions
        const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _QuickCard(title: 'Start Shift', icon: Icons.auto_awesome_outlined, onTap: onStartShift)),
            const SizedBox(width: 10),
            Expanded(child: _QuickCard(title: 'Add Win', icon: Icons.emoji_events_outlined, onTap: onAddWin)),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Chip(label: Text(text));
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.title, required this.icon, required this.onTap, super.key});
  final String title; final IconData icon; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}
