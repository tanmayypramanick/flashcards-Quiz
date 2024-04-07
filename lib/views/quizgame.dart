import 'package:flutter/material.dart';
import '/models/deck.dart';

class Quiz extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String deckName;

  const Quiz({required this.flashcards, required this.deckName, Key? key})
      : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int currentIndex = 0;
  bool isFlipped = false;

  int seen = 1; // Initializing the variables to store the count
  int flip = 0;
  int peek = 0;
  int answer = 1;

  List<Flashcard> shuffledFlashcards = []; // List to store shuffled flashcards
  List<int> flippedCards = []; // List to track flipped cards
  List<int> seenedCards = [0]; // List to track seen cards

  @override
  void initState() {
    super.initState();
    // Shuffle the list of flashcards and initialize the quiz
    shuffledFlashcards = List<Flashcard>.from(widget.flashcards)..shuffle();
  }

  // Method to handle going to the previous flashcard
  void PreviousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        // If the current card is not seen, increment the seen count and mark it as seen
        if (!seenedCards.contains(currentIndex)) {
          seen++;
          seenedCards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    } else {
      setState(() {
        // If at the first card, go to the last card in the deck
        currentIndex = shuffledFlashcards.length - 1;
        if (!seenedCards.contains(currentIndex)) {
          seen++;
          seenedCards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    }
  }

  // Method to handle going to the next flashcard
  void NextCard() {
    if (currentIndex < shuffledFlashcards.length - 1) {
      setState(() {
        currentIndex++;
        // If the current card is not seen, increment the seen count and mark it as seen
        if (!seenedCards.contains(currentIndex)) {
          seen++;
          seenedCards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    } else {
      setState(() {
        // If at the last card, go to the first card in the deck
        currentIndex = 0;
        if (!seenedCards.contains(currentIndex)) {
          seen++;
          seenedCards.add(currentIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    }
  }

  // Method to handle flipping the flashcard
  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      // If the card is flipped, seen, and not already flipped, increment flip count and peek count
      if (isFlipped &&
          seenedCards.contains(currentIndex) &&
          !flippedCards.contains(currentIndex)) {
        flip++;
        answer = seen;
        flippedCards.add(currentIndex);
        peek++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deckName} Quiz'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromARGB(255, 22, 33, 43),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Flashcard display container
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFlipped
                  ? Color.fromARGB(255, 136, 214, 46)
                  : Color.fromARGB(255, 255, 175, 26),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              isFlipped
                  ? shuffledFlashcards[currentIndex].answer
                  : shuffledFlashcards[currentIndex].question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Navigation buttons (Previous, Flip, Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_sharp),
                onPressed: PreviousCard,
                color: Colors.black,
              ),
              IconButton(
                icon: const Icon(Icons.flip_to_front_outlined),
                onPressed: flipCard,
                color: Colors.black,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_sharp),
                onPressed: NextCard,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          Text(
            'Seen: $seen out of ${shuffledFlashcards.length} cards',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Peeked at $peek out of $answer answers',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
