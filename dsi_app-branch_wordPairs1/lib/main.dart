import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dsi_app/view/word_pair_view.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DSIApp());
}

///Classe principal que representa o App.
///O uso do widget do tipo Stateful evita a reinicialização do Firebase cada vez
///que o App é reconstruído.
class DSIApp extends StatefulWidget {
  ///Cria o estado do app.
  @override
  _DSIAppState createState() => _DSIAppState();
}

///O estado do app.
class _DSIAppState extends State<DSIApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  ///Constrói o App a partir do FutureBuilder, após o carregamento do Firebase.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(context);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildApp(context);
        }
        return _buildLoading(context);
      },
    );
  }

  ///Constroi o componente que apresenta o erro no carregamento do Firebase.
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

  ///Constrói o App e suas configurações.
  Widget _buildApp(BuildContext context) {
    return MaterialApp(
      title: 'DSI App (BSI UFRPE)',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      initialRoute: HomePage.routeName,
      routes: _buildRoutes(context),
    );
  }

  ///Método utilizado para configurar as rotas.
  Map<String, WidgetBuilder> _buildRoutes(BuildContext context) {
    return {
      WordPairUpdatePage.routeName: (context) => WordPairUpdatePage(),
    };
  }
}
