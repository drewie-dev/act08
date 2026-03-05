import 'package:flutter/material.dart';

void main() {
  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  final List<String> folders = const [
    "Hearts",
    "Spades",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Organizer"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: folders.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final suit = folders[index];

          return Card(
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardsScreen(suit: suit),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// ♥ ♠ SUIT SYMBOL
                  Text(
                    suit == "Hearts" ? "♥" : "♠",
                    style: TextStyle(
                      fontSize: 60,
                      color: suit == "Hearts"
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    suit,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardsScreen extends StatelessWidget {
  final String suit;

  const CardsScreen({super.key, required this.suit});

  final List<String> cards = const [
    "Ace",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "Jack",
    "Queen",
    "King"
  ];

  /// Generates the correct card image URL
  String cardImageUrl(String cardName, String suitName) {
    String rankCode;

    switch (cardName) {
      case "Ace":
        rankCode = "A";
        break;
      case "King":
        rankCode = "K";
        break;
      case "Queen":
        rankCode = "Q";
        break;
      case "Jack":
        rankCode = "J";
        break;
      default:
        rankCode = cardName;
    }

    final suitCode = suitName == "Hearts" ? "H" : "S";

    return "https://deckofcardsapi.com/static/img/$rankCode$suitCode.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(suit),
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final url = cardImageUrl(card, suit);

          return Card(
            child: ListTile(
              leading: SizedBox(
                width: 56,
                height: 56,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              title: Text(card),
              subtitle: Text(suit),
            ),
          );
        },
      ),
    );
  }
}