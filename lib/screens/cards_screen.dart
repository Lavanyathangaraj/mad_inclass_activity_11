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
      await folderRepo.updatePreviewImage(
          widget.folder.id!, loadedCards[0].imageUrl);
    }

    setState(() {
      cards = loadedCards;
    });
  }

  Future<void> _deleteCard(int id) async {
    await cardRepo.deleteCard(id);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: cards.isEmpty
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
                  onLongPress: () => _deleteCard(card.id!),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: card.imageUrl.isNotEmpty
                              ? Image.asset(card.imageUrl, fit: BoxFit.contain) // <--- Image.asset
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
    );
  }
}