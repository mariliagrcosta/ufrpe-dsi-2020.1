import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dsi_app/controller/word_pair_controller.dart';
import 'package:dsi_app/model/word_pair_model.dart';

///Exibe uma mensagem no SnackBar.
void _showMessage(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        //
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

//Constroi o componente que apresenta o erro no carregamento do Firebase.
Widget _buildError(context) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: Text(
        'Erro ao carregar os dados do App. \n'
        'Tente novamente mais tarde',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}

///Constrói o componente de load.
Widget _buildLoading(context) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Text(
            'Carregando...',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 16.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ),
  );
}

///Página inicial que apresenta o [BottomNavigationBar], onde cada
///[BottomNavigationBarItem] é uma página do tipo [WordPairListPage].
class HomePage extends StatefulWidget {
  ///Nome da rota referente à página Home.
  static const routeName = '/';

  ///Cria o estado da página Home.
  @override
  _HomePageState createState() => _HomePageState();
}

///O estado equivalente ao [StatefulWidget] [HomePage].
class _HomePageState extends State<HomePage> {
  ///A página atual em que o [BottomNavigationBar] se encontra.
  int _pageIndex = 0;

  ///As 3 páginas do [HomePage].
  ///A primeira apresenta todas as palavras, a segunda apresenta as palavras que
  ///o usuário gosta e a terceira apresenta as palavras que o usuário não gosta.
  List<Widget> _pages = [
    WordPairListPage(null),
    WordPairListPage(true),
    WordPairListPage(false),
  ];

  ///Método utilizado para alterar a página atual do [HomePage].
  void _changePage(int value) {
    setState(() {
      _pageIndex = value;
    });
  }

  ///Constroi a tela do [HomePage], incluindo um [BottomNavigationBar]
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
            label: 'Todas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumb_up_outlined),
            label: 'Curtidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumb_down_outlined),
            label: 'Não Curtidas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, WordPairUpdatePage.routeName),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}

///Página que apresenta a listagem de palavras.
class WordPairListPage extends StatefulWidget {
  ///Atributo que determina as palavras que serão exibidas na listagem.
  final bool _filter;

  ///Construtor da classe
  WordPairListPage(this._filter);

  ///Método responsável por criar o objeto estado.
  @override
  _WordPairListPageState createState() => _WordPairListPageState();
}

///Esta classe é o estado da classe [WordPairListPage].
class _WordPairListPageState extends State<WordPairListPage> {
  final DSIWordPairController _controller = DSIWordPairController();

  ///Map com os ícones utilizados no [BottomNavigationBar].
  final _icons = {
    null: Icon(Icons.thumbs_up_down_outlined),
    true: Icon(Icons.thumb_up, color: Colors.indigoAccent),
    false: Icon(Icons.thumb_down, color: Colors.deepOrange),
  };

  ///Método getter para retornar os itens. Os itens são ordenados utilizando a
  ///ordenação definida na classe [DSIWordPair].
  ///
  ///Dependendo do que está setado no atributo [widget._filter], este método
  ///retorna todas as palavras, as palavras curtidas ou as palavras não curtidas.
  Future<Iterable<DSIWordPair>> get items {
    FutureOr<Iterable<DSIWordPair>> result;
    if (widget._filter == null) {
      result = _controller.getAll();
    } else {
      result = _controller
          .getByFilter((element) => element.favourite == widget._filter);
    }
    return result;
  }

  ///Altera o estado de curtida da palavra.
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
    _controller.save(wordPair).then((value) {
      _showMessage(context, 'A operação foi realizada com sucesso.');
      setState(() {});
    }).onError((error, stackTrace) {
      _showMessage(context, 'A operação não foi realizada.');
    });
  }

  ///Constroi a listagem de itens.
  ///Note que é dobrada a quantidade de itens, para que a cada índice par, se
  ///inclua um separador ([Divider]) na listagem.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: items,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(context);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          var wordPairs = snapshot.data;
          return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wordPairs.length * 2,
              itemBuilder: (BuildContext _context, int i) {
                if (i.isOdd) {
                  return Divider();
                }
                final int index = i ~/ 2;
                return _buildRow(
                    context, index + 1, wordPairs.elementAt(index));
              });
        }

        return _buildLoading(context);
      },
    );
  }

  ///Constroi uma linha da listagem a partir do par de palavras e do índice.
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
          _controller.delete(wordPair).then((value) {
            _showMessage(context, 'A operação foi realizada com sucesso.');
            setState(() {});
          }).onError((error, stackTrace) {
            _showMessage(context, 'A operação não foi realizada.');
          });
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

  ///Exibe a tela de atualização do par de palavras.
  _updateWordPair(BuildContext context, DSIWordPair wordPair) {
    Navigator.pushNamed(context, WordPairUpdatePage.routeName,
        arguments: wordPair);
  }
}

///Página que apresenta a tela de atualização do par de palavras.
class WordPairUpdatePage extends StatefulWidget {
  static const routeName = '/wordpair/update';

  ///Construtor da classe
  WordPairUpdatePage();

  ///Cria o estado da página de atualização de palavras.
  @override
  _WordPairUpdatePageState createState() => _WordPairUpdatePageState();
}

///Esta classe é o estado da classe que atualiza os pares de palavras.
class _WordPairUpdatePageState extends State<WordPairUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  DSIWordPairController _controller = DSIWordPairController();
  DSIWordPair _wordPair;
  String _newFirst;
  String _newSecond;

  ///Método responsável por criar a tela de atualização do par de palavras.
  @override
  Widget build(BuildContext context) {
    _wordPair = ModalRoute.of(context).settings.arguments;
    if (_wordPair == null) {
      _wordPair = DSIWordPair();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('DSI App (BSI UFRPE)'),
      ),
      body: _buildForm(context),
    );
  }

  ///Método utilizado para criar o corpo da tela de atualização do par de palavras.
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
              return value.isEmpty ? 'Palavra inválida' : null;
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
          )
        ],
      ),
    );
  }

  ///Método que valida o formulário e salva os dados no par de palavras.
  void _save(BuildContext context) {
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _formKey.currentState.save();
      _updateWordPair();
    });

    //Retorna para a home  e remove o histórico de navegação para evitar a
    //exibição do botão de 'back' na appbar.
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomePage.routeName,
      (Route<dynamic> route) => false,
    );
  }

  ///Recupera os dados que os campos de texto atualizaram nos atributos da classe
  ///e atualiza o par de palavras.
  void _updateWordPair() {
    _wordPair.first = _newFirst;
    _wordPair.second = _newSecond;
    _controller.save(_wordPair).then((value) {
      _showMessage(context, 'A operação foi realizada com sucesso.');
      setState(() {});
    }).onError((error, stackTrace) {
      _showMessage(context, 'A operação não foi realizada.');
    });
  }
}
