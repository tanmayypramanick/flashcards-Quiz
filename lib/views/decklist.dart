import 'package:flutter/material.dart';
import '/models/deck.dart';
import 'flashcardlist.dart';
import '/utils/db_helper.dart';
import 'package:mp3/main.dart';

class DeckList extends StatefulWidget {
  const DeckList({Key? key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  late List<Deck> decks;

  @override
  void initState() {
    super.initState();
    // Load the decks from the database when the widget is first created
    loadDecks();
  }

  // Asynchronous function to load decks from the database
  Future<void> loadDecks() async {
    final dbHelper = DBHelper();
    final deckList = await dbHelper.getAllDecks();
    setState(() {
      decks = deckList;
    });
  }

  // Function to handle editing a deck
  Future<void> _editDeck(int index) async {
    // Get the old deck name to display in the text field
    String oldDeckName = decks[index].title;
    TextEditingController deckNameController =
        TextEditingController(text: oldDeckName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Deck Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: deckNameController,
                decoration: const InputDecoration(labelText: 'Deck Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Get the new deck name from the text field
                final newDeckName = deckNameController.text;

                if (newDeckName.isNotEmpty) {
                  final dbHelper = DBHelper();
                  // Create an updated deck with the new name
                  final updatedDeck =
                      Deck(id: decks[index].id, title: newDeckName);
                  await updatedDeck.dbUpdate(dbHelper);

                  // Update the deck title in the list
                  setState(() {
                    decks[index].title = newDeckName;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteDeck(index); // Call function to delete the deck
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle deleting a deck
  void _deleteDeck(int index) async {
    final dbHelper = DBHelper();
    final deckId = decks[index].id;

    if (deckId != null) {
      // Delete related flashcards first
      await dbHelper.deleteFlashcardsForDeck(deckId);

      // Then, delete the deck from the database
      await dbHelper.delete('deck', deckId);

      // Update the deck list
      setState(() {
        decks.removeAt(index);
      });
    }
  }

  // Function to add a new deck
  Future<void> _addDeck() async {
    TextEditingController deckNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Deck Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: deckNameController,
                decoration: const InputDecoration(labelText: 'Deck Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Get the new deck name from the text field
                final newDeckName = deckNameController.text;

                if (newDeckName.isNotEmpty) {
                  final dbHelper = DBHelper();
                  // Create a new deck with the entered name
                  final newDeck = Deck(title: newDeckName);
                  await newDeck.dbSave(dbHelper);

                  setState(() {
                    decks.add(newDeck); // Add the new deck to the list
                  });
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to navigate to the flashcards screen for a specific deck
  void _showFlashcards(int index) {
    final deck = decks[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardList(deck: deck),
      ),
    );
  }

  // Function to download data (Load JSON data and update decks)
  void _downloadData() async {
    await loadJSONData();
    loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcard App"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 22, 33, 43),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_sharp),
            onPressed: _downloadData,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final maxDecksInRow = (screenWidth / 200).floor();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: maxDecksInRow > 0 ? maxDecksInRow : 1,
              childAspectRatio: 1.0,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Card(
                  key: UniqueKey(),
                  color: Color.fromARGB(255, 255, 175, 26),
                  child: InkWell(
                    onTap: () {
                      _showFlashcards(index);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Center(
                            child: Text(deck.title),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editDeck(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addDeck();
        },
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 22, 33, 43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
