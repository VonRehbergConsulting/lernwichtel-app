import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/tile_style.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fund_repository.dart';

/// Prominente Foto-Leiste „Deine Fundstücke zu »x«": zeigt die vom Kind selbst
/// gesammelten Fotos zu einem Laut/einer Silbe – ruft sie beim Lernen dieses
/// Lauts wieder ins Gedächtnis. Erscheint nur, wenn es passende Fotos gibt.
class FundstueckeStrip extends StatefulWidget {
  const FundstueckeStrip({
    super.key,
    required this.childId,
    required this.letter,
  });

  final int childId;

  /// Laut/Buchstabe bzw. Silbe (z. B. "m", "ei", "sch").
  final String letter;

  @override
  State<FundstueckeStrip> createState() => _FundstueckeStripState();
}

class _FundstueckeStripState extends State<FundstueckeStrip> {
  final _funds = getIt<FundRepository>();
  List<Fundstueck> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(FundstueckeStrip old) {
    super.didUpdateWidget(old);
    if (old.letter != widget.letter || old.childId != widget.childId) _load();
  }

  Future<void> _load() async {
    final items =
        await _funds.forChildAndLetter(widget.childId, widget.letter);
    if (!mounted) return;
    setState(() => _items = items);
  }

  void _openBig(Fundstueck fund) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
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
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔎', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deine Fundstücke zu „${widget.letter.toLowerCase()}"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TileStyle.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final fund = _items[i];
                return GestureDetector(
                  onTap: () => _openBig(fund),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(fund.filePath),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 96,
                        height: 96,
                        color: const Color(0xFFEEEEEE),
                        alignment: Alignment.center,
                        child: const Text('🖼️',
                            style: TextStyle(fontSize: 32)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
