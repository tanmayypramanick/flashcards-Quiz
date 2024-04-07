import '/utils/db_helper.dart';

class Deck {
  int? id;
  String title;

  Deck({
    this.id,
    required this.title,
  });

  Future<void> dbSave(DBHelper dbHelper) async {
    id = await dbHelper.insert('deck', {'title': title});
  }

  Future<void> dbUpdate(DBHelper dbHelper) async {
    await dbHelper.updateDeckTitle(id!, title);
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      title: map['title'],
    );
  }
}

class Flashcard {
  int? id;
  int deckId;
  String question;
  String answer;

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  Future<void> dbSave(DBHelper dbHelper) async {
    id = await dbHelper.insert('flashcard', {
      'deck_id': deckId,
      'question': question,
      'answer': answer,
    });
  }

  Future<void> dbDelete() async {
    if (id != null) {
      await DBHelper().delete('flashcard', id!);
    }
  }

  Future<void> dbUpdate(DBHelper dbHelper) async {
    if (id != null) {
      await dbHelper.updateFlashcard(id!, deckId, question, answer);
    }
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deck_id'],
      question: map['question'],
      answer: map['answer'],
    );
  }
}
