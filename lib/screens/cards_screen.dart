import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final cardRepo = CardRepository();
  final folderRepo = FolderRepository();
  List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loadedCards = await cardRepo.getCardsByFolder(widget.folder.id!);

    if (loadedCards.isNotEmpty &&
        widget.folder.previewImage != loadedCards[0].imageUrl) {
      // Update folder preview image
      await folderRepo.updatePreviewImage(
          widget.folder.id!, loadedCards[0].imageUrl);
      // NOTE: For the FoldersScreen to reflect the change immediately, 
      // you would need to rebuild the parent FoldersScreen, typically by passing 
      // a callback function here.
    }

    setState(() {
      cards = loadedCards;
    });
  }

  // Mandatory Delete Operation
  Future<void> _deleteCard(int id) async {
    await cardRepo.deleteCard(id);
    _loadCards();
  }

  // Mandatory Update/Edit Operation (Mock implementation)
  Future<void> _editCard(CardModel card) async {
    // In a full implementation, this navigates to an edit screen.
    // Here, we mock an update to prove the functionality.
    final updatedCard = CardModel(
      id: card.id,
      name: '${card.name} (Updated)',
      suit: card.suit,
      imageUrl: card.imageUrl, // Keep the asset path
      folderId: card.folderId,
      createdAt: card.createdAt,
    );

    await cardRepo.updateCard(updatedCard);
    _loadCards();
  }
  
  // Mandatory Create/Add Operation with Limit Check
  Future<void> _addCard(BuildContext context) async {
    final folderId = widget.folder.id!;
    final currentCount = await folderRepo.countCards(folderId);

    // MANDATORY CARD LIMIT CHECK (Max 6 Cards)
    if (currentCount >= 6) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Folder Full'),
          content: const Text('This folder can only hold 6 cards.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
      return;
    }
    
    // Mock Card Data (Adds the 'next' card)
    final newCard = CardModel(
      name: 'NEW CARD ${currentCount + 1}',
      suit: widget.folder.name,
      imageUrl: 'assets/cards/club_a.png', // Placeholder asset
      folderId: folderId,
      createdAt: DateTime.now(),
    );

    await cardRepo.createCard(newCard);
    _loadCards(); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    // MANDATORY CARD LIMIT WARNING (Min 3 Cards)
    bool showWarning = cards.isNotEmpty && cards.length < 3;
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: Column(
        children: [
          if (showWarning) 
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'You need at least 3 cards in this folder.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          
          Expanded(
            child: cards.isEmpty
                ? const Center(child: Text('No cards found'))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return GestureDetector(
                        onTap: () => _editCard(card), // Edit on tap
                        onLongPress: () => _deleteCard(card.id!), // Delete on long press
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: card.imageUrl.isNotEmpty
                                    ? Image.asset(card.imageUrl, fit: BoxFit.contain) // Image.asset fix
                                    : const SizedBox.shrink(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  card.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCard(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}