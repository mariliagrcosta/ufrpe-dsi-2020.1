import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  initWordPairs();
  runApp(DSIApp());
}

List<DSIWordPair> wordPairs;

void initWordPairs() {
  wordPairs = <DSIWordPair>[];
  for (var i = 0; i < 20; i++) {
    wordPairs.add(DSIWordPair());
  }
  wordPairs.sort();
}

String capitalize(String s) {
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

class DSIWordPair extends Comparable<DSIWordPair> {
  String first;
  String second;
  bool favourite;
  DSIWordPair() {
    WordPair wordPair = WordPair.random();
    this.first = capitalize(wordPair.first);
    this.second = capitalize(wordPair.second);
  }

  @override
  String toString() {
    return '${this.first}${this.second}';
  }

  @override
  int compareTo(DSIWordPair that) {
    int result = this.first.toLowerCase().compareTo(that.first.toLowerCase());
    if (result == 0) {
      result = this.first.toLowerCase().compareTo(that.first.toLowerCase());
    }
    return result;
  }
}

class DSIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSI App (BSI UFRPE)',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      initialRoute: HomePage.routeName,
      routes: _buildRoutes(context),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes(BuildContext context) {
    return {
      WordPairUpdatePage.routeName: (context) => WordPairUpdatePage(),
    };
  }
}

class HomePage extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  List<Widget> _pages = [
    WordPairListPage(null),
    WordPairListPage(true),
    WordPairListPage(false)
  ];

  void _changePage(int value) {
    setState(() {
      _pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DSI App (BSI UFRPE)'),
      ),
      body: _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _changePage,
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Palavras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumb_up_outlined),
            label: 'Curti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumb_down_outlined),
            label: 'Não Curti',
          ),
        ],
      ),
    );
  }
}

class WordPairListPage extends StatefulWidget {
  final bool _filter;

  WordPairListPage(this._filter);

  @override
  _WordPairListPageState createState() => _WordPairListPageState();
}

class _WordPairListPageState extends State<WordPairListPage> {
  List<DSIWordPair> searchList;
  final _icons = {
    null: Icon(Icons.thumbs_up_down_outlined),
    true: Icon(Icons.thumb_up, color: Colors.blue),
    false: Icon(Icons.thumb_down, color: Colors.red),
  };

  @override
  void initState() {
    super.initState();
    wordPairs.sort();
    searchList = List.from(wordPairs);
    searchList.sort();
  }

  Iterable<DSIWordPair> get items {
    List<DSIWordPair> result;
    if (widget._filter == null) {
      result = wordPairs;
    } else {
      result = wordPairs
          .where((element) => element.favourite == widget._filter)
          .toList();
    }

    return result;
  }

  _toggleFavourite(DSIWordPair wordPair) {
    bool like = wordPair.favourite;
    if (widget._filter != null) {
      wordPair.favourite = null;
    } else if (like == null) {
      wordPair.favourite = true;
    } else if (like == true) {
      wordPair.favourite = false;
    } else {
      wordPair.favourite = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.all(16),
              hintText: 'Type a word'),
          onChanged: (string) {
            setState(() {
              searchList = string.isEmpty
                  ? items
                  : items
                      .where((element) => element
                          .toString()
                          .toLowerCase()
                          .contains(string.toLowerCase()))
                      .toList();
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchList.length * 2,
            itemBuilder: (BuildContext context, int i) {
              if (i.isOdd) {
                return Divider();
              }
              final int index = i ~/ 2;
              return _buildRow(context, index + 1, searchList.elementAt(index));
            },
          ),
        )
      ],
    );
  }

  Widget _buildRow(BuildContext context, int index, DSIWordPair wordPair) {
    return Dismissible(
      key: Key(wordPair.toString()),
      background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          )),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          searchList.remove(wordPair);
          wordPairs.remove(wordPair);
          wordPairs.add(DSIWordPair());
        });
      },
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirmação"),
              content: const Text("Tem certeza que deseja deletar esse item?"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Sim")),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Não"),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        title: Text('$index. ${(wordPair)}'),
        trailing: TextButton(
          onPressed: () => _toggleFavourite(wordPair),
          child: _icons[wordPair.favourite],
        ),
        onTap: () => _updateWordPair(context, wordPair),
      ),
    );
  }

  _updateWordPair(BuildContext context, DSIWordPair wordPair) {
    Navigator.pushNamed(context, WordPairUpdatePage.routeName,
        arguments: wordPair);
  }
}

class WordPairUpdatePage extends StatefulWidget {
  static const routeName = '/wordpair/update';

  WordPairUpdatePage();

  @override
  _WordPairUpdatePageState createState() => _WordPairUpdatePageState();
}

class _WordPairUpdatePageState extends State<WordPairUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  DSIWordPair _wordPair;
  String _newFirst;
  String _newSecond;

  @override
  Widget build(BuildContext context) {
    _wordPair = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('DSI App (BSI UFRPE)'),
      ),
      body: _buildForm(context),
    );
  }

  _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 16.0,
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Primeira'),
            validator: (String value) {
              return value.isEmpty ? 'Palavra inválida' : null;
            },
            onSaved: (newValue) => _newFirst = newValue,
            initialValue: _wordPair.first,
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Segunda'),
            validator: (String value) {
              return value.isEmpty ? 'Palavra inválida.' : null;
            },
            onSaved: (newValue) => _newSecond = newValue,
            initialValue: _wordPair.second,
          ),
          SizedBox(
            width: double.infinity,
          ),
          ElevatedButton(
            onPressed: () => _save(context),
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _formKey.currentState.save();
      _updateWordPair();
      HomePage();
    });
    Navigator.pop(context, HomePage.routeName);
  }

  void _updateWordPair() {
    _wordPair.first = _newFirst;
    _wordPair.second = _newSecond;
  }
}
