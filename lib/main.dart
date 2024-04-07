import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/deck.dart';
import 'views/decklist.dart';
import '/utils/db_helper.dart';

// Function to load JSON data from assets and fill the database
Future<void> loadJSONData() async {
  // Load JSON data from assets folder using root.Bundle
  final jsonContent = await rootBundle.loadString('assets/flashcards.json');
  final List<dynamic> jsonList = jsonDecode(jsonContent);

  for (final dynamic map in jsonList) {
    final deckTitle = map['title'];
    final flashcards = map['flashcards'];

    final dbHelper = DBHelper();

    // Create a new deck with the extracted title and save it to the database
    final deck = Deck(title: deckTitle);
    await deck.dbSave(dbHelper);

    // Iterate through flashcards, extract data, and save to the database
    for (final flashcardMap in flashcards) {
      final question = flashcardMap['question'];
      final answer = flashcardMap['answer'];

      final flashcard = Flashcard(
        deckId: deck.id!,
        question: question,
        answer: answer,
      );

      await flashcard.dbSave(dbHelper);
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit(); // Initialize the SQFlite ffi plugin
  //databaseFactory = databaseFactoryFfi; // Use ffi database factory

  final dbHelper = DBHelper();
  final decks = await dbHelper.getAllDecks();

  // If there are no decks in the database, load data from JSON
  if (decks.isEmpty) {
    await loadJSONData();
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DeckList(),
  ));
}
