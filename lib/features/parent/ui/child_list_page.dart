import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/repositories/child_repository.dart';
import '../../profiles/bloc/profiles_bloc.dart';
import 'child_create_wizard.dart';
import 'child_detail_page.dart';

/// Kinder verwalten: Liste, Anlegen, tippen fuer Details (Umbenennen/Loeschen/
/// Fortschritt).
class ChildListPage extends StatelessWidget {
  const ChildListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfilesBloc(getIt<ChildRepository>())..add(const ProfilesStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Kinder')),
        body: SafeArea(
          child: BlocBuilder<ProfilesBloc, ProfilesState>(
            builder: (context, state) {
              if (state.status == ProfilesStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final child in state.children)
                    Card(
                      child: ListTile(
                        leading: Text(
                          (child.avatar?.isNotEmpty ?? false)
                              ? child.avatar!
                              : '🙂',
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(child.name,
                            style: const TextStyle(fontSize: 20)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final bloc = context.read<ProfilesBloc>();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChildDetailPage(child: child),
                            ),
                          );
                          bloc.add(const ProfilesStarted());
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: const Text('Kind hinzufügen'),
          ),
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final bloc = context.read<ProfilesBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChildCreateWizard()),
    );
    bloc.add(const ProfilesStarted());
  }
}
