import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  final CardRepository _cardRepo = CardRepository();

  List<Folder> _folders = [];
  final Map<int, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _loading = true);

    final folders = await _folderRepo.getAllFolders();
    final Map<int, int> counts = {};

    for (final f in folders) {
      if (f.id == null) continue;
      counts[f.id!] = await _cardRepo.getCardCountByFolder(f.id!);
    }

    setState(() {
      _folders = folders;
      _counts
        ..clear()
        ..addAll(counts);
      _loading = false;
    });
  }

  String _suitImage(String suit) {
    switch (suit) {
      case 'Hearts':
        return 'assets/images/hearts.png';
      case 'Spades':
        return 'assets/images/spades.png';
      default:
        return 'assets/images/hearts.png';
    }
  }

  Color _suitColor(String suit) {
    return suit == 'Hearts' ? Colors.red : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
        actions: [
          IconButton(onPressed: _loadFolders, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                final id = folder.id ?? -1;
                final count = _counts[id] ?? 0;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardsScreen(folder: folder),
                        ),
                      );
                      await _loadFolders();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _suitImage(folder.folderName),
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 56),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            folder.folderName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _suitColor(folder.folderName),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('$count cards'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}