import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final folderRepo = FolderRepository();
  List<Folder> folders = [];
  Map<int, int> folderCardCounts = {};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final allFolders = await folderRepo.getAllFolders();
    Map<int, int> counts = {};
    for (var f in allFolders) {
      counts[f.id!] = await folderRepo.countCards(f.id!);
    }
    setState(() {
      folders = allFolders;
      folderCardCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: folders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                final count = folderCardCounts[folder.id!] ?? 0;
                return ListTile(
                  leading: folder.previewImage != null
                      ? Image.asset(folder.previewImage!) // <--- Image.asset
                      : const Icon(Icons.folder),
                  title: Text(folder.name),
                  subtitle: Text('$count cards'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardsScreen(folder: folder),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}