import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../data/repositories/child_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../profiles/bloc/profiles_bloc.dart';
import '../profiles/ui/profile_selection_page.dart';
import 'welcome_page.dart';

/// Einstiegspunkt: zeigt beim allerersten Start den Willkommens-Screen,
/// danach immer direkt die Profilauswahl.
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _settings = getIt<SettingsRepository>();
  bool? _welcomeSeen;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final seen = await _settings.welcomeSeen();
    if (!mounted) return;
    setState(() => _welcomeSeen = seen);
  }

  Future<void> _finishWelcome() async {
    await _settings.markWelcomeSeen();
    if (!mounted) return;
    setState(() => _welcomeSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    final seen = _welcomeSeen;
    if (seen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!seen) {
      return WelcomePage(onStart: _finishWelcome);
    }
    return BlocProvider(
      create: (_) => ProfilesBloc(getIt<ChildRepository>())
        ..add(const ProfilesStarted()),
      child: const ProfileSelectionPage(),
    );
  }
}
