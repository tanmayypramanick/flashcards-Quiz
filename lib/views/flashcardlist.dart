import 'package:flutter/material.dart';
import '/models/deck.dart';
import '/utils/db_helper.dart';
import 'quizgame.dart';

class FlashcardList extends StatefulWidget {
  final Deck deck;

  const FlashcardList({required this.deck, Key? key}) : super(key: key);

  @override
  State<FlashcardList> createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
  late List<Flashcard> flashcards;
  bool isSorted = false; // Track whether flashcards are sorted.
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    // Load flashcards for the selected deck from the database
    loadFlashcards();
  }

  // Asynchronous function to load flashcards from the database
  Future<void> loadFlashcards() async {
    final dbHelper = DBHelper();
    final flashcardList = await dbHelper.getFlashcardsForDeck(widget.deck.id!);
    setState(() {
      flashcards = flashcardList;
    });
  }

  // Function to toggle sorting order of flashcards
  void _toggleSortingOrder() {
    setState(() {
      isAscending = !isAscending;
      isSorted = !isSorted;
      flashcards.sort((a, b) {
        if (isAscending) {
          return a.question.compareTo(b.question);
        } else {
          return b.question.compareTo(a.question);
        }
      });
    });
  }

  // Function to edit a flashcard
  Future<void> _editFlashcard(int index) async {
    String oldQuestion = flashcards[index].question;
    String oldAnswer = flashcards[index].answer;
    TextEditingController questionController =
        TextEditingController(text: oldQuestion);
    TextEditingController answerController =
        TextEditingController(text: oldAnswer);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newQuestion = questionController.text;
                final newAnswer = answerController.text;

                if (newQuestion.isNotEmpty && newAnswer.isNotEmpty) {
                  final dbHelper = DBHelper();
                  // Create an updated flashcard with new question and answer
                  final updatedFlashcard = Flashcard(
                    id: flashcards[index].id,
                    deckId: widget.deck.id!,
                    question: newQuestion,
                    answer: newAnswer,
                  );

                  await updatedFlashcard.dbUpdate(dbHelper);
                  setState(() {
                    flashcards[index] = updatedFlashcard;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteFlashcard(
                    index); // Call function to delete the flashcard
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete a flashcard
  Future<void> _deleteFlashcard(int index) async {
    final dbHelper = DBHelper();
    final flashcardId = flashcards[index].id;

    if (flashcardId != null) {
      // Delete the flashcard from the database
      await dbHelper.delete('flashcard', flashcardId);

      // Update the flashcard list
      setState(() {
        flashcards.removeAt(index);
      });
    }
  }

  // Function to add a new flashcard
  Future<void> _addFlashcard() async {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newQuestion = questionController.text;
                final newAnswer = answerController.text;

                if (newQuestion.isNotEmpty && newAnswer.isNotEmpty) {
                  final dbHelper = DBHelper();
                  // Create a new flashcard with the entered question and answer
                  final newFlashcard = Flashcard(
                    deckId: widget.deck.id!,
                    question: newQuestion,
                    answer: newAnswer,
                  );

                  await newFlashcard.dbSave(dbHelper);
                  setState(() {
                    flashcards
                        .add(newFlashcard); // Add the new flashcard to the list
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to navigate to the quiz screen
  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(
          flashcards: flashcards,
          deckName: widget.deck.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.deck.title)),
        actions: <Widget>[
          IconButton(
            icon: Icon(isSorted ? Icons.sort_by_alpha : Icons.access_time),
            onPressed: _toggleSortingOrder,
          ),
          IconButton(
            icon: Icon(Icons.play_circle_filled),
            onPressed: _navigateToQuiz,
          ),
        ],
        backgroundColor: Color.fromARGB(255, 22, 33, 43),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth / 200).floor();
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
              childAspectRatio: 1.2,
            ),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = flashcards[index];
              return Card(
                key: UniqueKey(),
                color: Color.fromARGB(255, 230, 156, 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  onTap: () {
                    _editFlashcard(index);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            flashcard.question,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ],
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
          _addFlashcard();
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 22, 33, 43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
