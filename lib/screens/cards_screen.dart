import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();

  List<PlayingCard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _loading = true);

    final cards = await _cardRepo.getCardsByFolderId(widget.folder.id!);

    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  // Convert card name + suit into deckofcardsapi image URL
  String _getCardImage(String name, String suit) {
    String cardCode;

    switch (name) {
      case 'Ace':
        cardCode = 'A';
        break;
      case 'King':
        cardCode = 'K';
        break;
      case 'Queen':
        cardCode = 'Q';
        break;
      case 'Jack':
        cardCode = 'J';
        break;
      default:
        cardCode = name;
    }

    String suitCode;

    switch (suit) {
      case 'Hearts':
        suitCode = 'H';
        break;
      case 'Spades':
        suitCode = 'S';
        break;
      default:
        suitCode = 'H';
    }

    return "https://deckofcardsapi.com/static/img/$cardCode$suitCode.png";
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('Delete "${card.cardName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cardRepo.deleteCard(card.id!);
      await _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.folderName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final c = _cards[index];

                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        _getCardImage(c.cardName, c.suit),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    title: Text(c.cardName),
                    subtitle: Text(c.suit),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteCard(c),
                    ),
                  ),
                );
              },
            ),
    );
  }
}