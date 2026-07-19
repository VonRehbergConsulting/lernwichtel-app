import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fund_repository.dart';

/// „Meine Fundstücke": die bei der Laut-Jagd behaltenen Fotos eines Kindes.
/// Gemeinsam zum Wiederansehen gedacht – schafft einen persönlichen Bezug zum
/// gelernten Laut. Tippen zeigt groß, langer Druck bietet Löschen an (Eltern).
class FundstueckePage extends StatefulWidget {
  const FundstueckePage({super.key, required this.child});
  final Child child;

  @override
  State<FundstueckePage> createState() => _FundstueckePageState();
}

class _FundstueckePageState extends State<FundstueckePage> {
  final _funds = getIt<FundRepository>();
  List<Fundstueck>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _funds.forChild(widget.child.id);
    if (!mounted) return;
    setState(() => _items = items);
  }

  void _openBig(Fundstueck fund) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FundViewer(fund: fund),
    ));
  }

  Future<void> _confirmDelete(Fundstueck fund) async {
    final del = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fundstück löschen?'),
        content: const Text('Das Foto wird endgültig entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828)),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (del != true) return;
    await _funds.delete(fund);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: Text('Meine Fundstücke · ${widget.child.name}')),
      body: SafeArea(
        child: items == null
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? _empty()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        _FundCard(
                      fund: items[i],
                      onTap: () => _openBig(items[i]),
                      onLongPress: () => _confirmDelete(items[i]),
                    ),
                  ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📸', style: TextStyle(fontSize: 72)),
            SizedBox(height: 16),
            Text(
              'Noch keine Fundstücke.\n'
              'Geht auf Laut-Schatzsuche und behaltet\n'
              'ein schönes Foto – dann erscheint es hier.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({
    required this.fund,
    required this.onTap,
    required this.onLongPress,
  });

  final Fundstueck fund;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(fund.filePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: const Color(0xFFEEEEEE),
                alignment: Alignment.center,
                child: const Text('🖼️', style: TextStyle(fontSize: 40)),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF07A54),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Text(
                  fund.letter,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ein Fundstück bildschirmfüllend.
class _FundViewer extends StatelessWidget {
  const _FundViewer({required this.fund});
  final Fundstueck fund;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Laut „${fund.letter}"'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(fund.filePath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
