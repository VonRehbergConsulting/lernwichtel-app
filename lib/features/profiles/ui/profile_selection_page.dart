import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/error_view.dart';
import '../../../data/db/database.dart';
import '../../parent/parent_gate.dart';
import '../../parent/ui/child_create_wizard.dart';
import '../../parent/ui/parent_home_page.dart';
import '../bloc/profiles_bloc.dart';
import 'child_home_page.dart';

/// Startbildschirm: Kind waehlt sein Profil (grosse Kacheln mit Avatar).
class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wer lernt heute?'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Eltern-Bereich',
              iconSize: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _openParentArea(context),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProfilesBloc, ProfilesState>(
        builder: (context, state) {
          if (state.status == ProfilesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfilesStatus.error) {
            return ErrorView(
              onRetry: () =>
                  context.read<ProfilesBloc>().add(const ProfilesStarted()),
            );
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  for (final child in state.children)
                    _ProfileTile(child: child),
                  const _AddProfileTile(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openParentArea(BuildContext context) async {
    final navigator = Navigator.of(context);
    final ok = await confirmParent(context);
    if (!ok) return;
    await navigator.push(
      MaterialPageRoute(builder: (_) => const ParentHomePage()),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.child});
  final Child child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatar = child.avatar;
    return Card(
      color: scheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChildHomePage(child: child),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (avatar != null && avatar.isNotEmpty) ? avatar : '🙂',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 12),
            Text(
              child.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showCreateDialog(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 64, color: scheme.primary),
            const SizedBox(height: 12),
            const Text('Neues Kind', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    // Die Profil-Liste aktualisiert sich per Stream automatisch.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChildCreateWizard()),
    );
  }
}
