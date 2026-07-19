import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/utils/slug.dart';
import '../../../data/repositories/reading_repository.dart';

/// Eltern-Bereich: eigenes Foto zu einem Wort hinterlegen (profooluebergreifend).
/// Ist keines hinterlegt, zeigt die App das generierte Standardbild.
class WordImagesPage extends StatefulWidget {
  const WordImagesPage({super.key});

  @override
  State<WordImagesPage> createState() => _WordImagesPageState();
}

class _WordImagesPageState extends State<WordImagesPage> {
  final _reading = getIt<ReadingRepository>();
  final _picker = ImagePicker();

  List<WordWithImage> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _reading.allWordsWithImages();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _pick(WordWithImage item, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1024);
    if (picked == null) return;

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'wordimages'))
      ..createSync(recursive: true);
    final ext = p.extension(picked.path);
    final dest = p.join(dir.path, '${wortSlug(item.word.word)}$ext');
    await File(picked.path).copy(dest);

    await _reading.setWordImage(item.word.id, dest, item.word.word);
    await _load();
  }

  Future<void> _remove(WordWithImage item) async {
    await _reading.clearWordImage(item.word.id);
    await _load();
  }

  void _showOptions(WordWithImage item) {
    final hasCustom =
        item.imagePath != null && File(item.imagePath!).existsSync();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Foto aufnehmen'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pick(item, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Aus Galerie wählen'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pick(item, ImageSource.gallery);
              },
            ),
            if (hasCustom)
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Eigenes Bild entfernen'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _remove(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eigene Bilder')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  final hasCustom = item.imagePath != null &&
                      File(item.imagePath!).existsSync();
                  return ListTile(
                    leading: SizedBox(
                      width: 52,
                      height: 52,
                      child: _Thumb(item: item),
                    ),
                    title: Text(item.word.word,
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(hasCustom ? 'eigenes Foto' : 'Standardbild'),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _showOptions(item),
                  );
                },
              ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});
  final WordWithImage item;

  @override
  Widget build(BuildContext context) {
    final custom = item.imagePath;
    final Widget img;
    if (custom != null && File(custom).existsSync()) {
      img = Image.file(File(custom), fit: BoxFit.cover);
    } else {
      img = Image.asset(
        'assets/images/standard/${wortSlug(item.word.word)}.webp',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.image_not_supported_outlined),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: img);
  }
}
