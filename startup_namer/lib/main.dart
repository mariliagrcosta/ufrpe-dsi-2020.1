import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() =>
    runApp(MyApp()); //Use arrow notation for one-line functions or methods.

class MyApp extends StatelessWidget {
  //The app extends StatelessWidget (immutable) makes the app itself a widget.
  @override
  //The build() method describes how to display the widget in terms of other, lower level widgets.
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Color(0xff630F96),
        ),
        home: RandomWords()); //home is a RandomWords widget
  }
}

//Stateful widgets maintain state that might change during the lifetime of the widget.
class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  //Stores the suggested word pairings.
  final _suggestions = <WordPair>[];
  //Stores the word pairings that the user favorited.
  final _saved = <WordPair>{};
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext) {
    //The Scaffold provides a default app bar, and a body property that holds the widget tree for the home screen.
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    //The Navigator.push pushes the route to the Navigator's stack.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (WordPair pair) {
              //Code that generates the ListTile rows.
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          //Adds horizontal spacing between each ListTile.
          //The divided variable holds the final rows converted to a list by the convenience function, toList().
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          //The Scaffold contains the app bar for the new route named SavedSuggestions
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Names'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  // _buildSuggestions methods builds the ListView that displays the suggested word pairing.
  Widget _buildRow(WordPair pair) {
    //Ensure that a word pairing has not already been added to favorites.
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      // Add the heart icons after the text.
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border_rounded,
        color: alreadySaved ? Color(0xff00B4D8) : null,
      ),
      onTap: () {
        //Calling setState() triggers a call to the build() method for the State object, resulting in an update to the UI.
        setState(() {
          //If a word entry has already been added to favorites, tapping it again removes it from favorites.
          if (alreadySaved) {
            _saved.remove(pair);
          }
          //If a word entry has not already been added to favorites, tapping it adds to favorite.
          else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        //The itemBuilder callback is called once per suggested word pairing, and places each suggestion into a ListTile row.
        itemBuilder: (context, i) {
          if (i.isOdd)
            return Divider(); // For odd rows, the function adds a Divider widget (visually separate the entries).

          //Calculates the actual number of word pairings in the ListView (minus the divider widgets).
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(
                10)); //If it reached the end of the available word pairings, generate 10 more and add them to the suggestions list.
          }
          return _buildRow(_suggestions[index]);
        });
  }
}
