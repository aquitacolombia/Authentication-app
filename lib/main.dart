import 'Auth/authentication.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //MODIFICAMOS TODA LA INFORMACION QUE PUEDE CAMBIAR
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  //PROPIEDADES ACCESIBLES DESEDE LA INSTANCIA DE LA CLASE
  var favorites = <WordPair>[];

  var authenticate = Authentication();
  late String sessionId = "";

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void getLogin(nombreusuario, secreto) {
    authenticate.login(nombreusuario, secreto);
    sessionId = authenticate.sessionId;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //ASPECTO DE TODA LA PAGINA INICIAL
  var selectedIndex = 0; // ← Add this property.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = Generator2Page();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      //EL LAYOUR BUILDER NOS PERMITE SER RESPONSIVE
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              //BARRAS DE NAVEGACION LATERAL
              child: NavigationRail(
                extended: constraints.maxWidth >= 1000, //RESPONSIVE
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  print('selected: $value');
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class Generator2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    String? session = appState.authenticate.sessionId;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair, session: session),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("NEW"),
              NextButton(appState: appState),
              SizedBox(width: 10),
              FavoriteButton(appState: appState, icon: icon),
            ],
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  //ASPECTO DE LA PAGINA SELECCIONADA EXPANDIDA
  @override
  Widget build(BuildContext context) {
    //CONECTAMOS EL HOME PAGE PARA QUE HAGA LISTENING A MyAppState
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    String? session = appState.authenticate.sessionId;
    //VARIABLES MUTABLES VAN FUERA DE LOS STATELESS WIDGETS
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //BigCard(pair: pair, sessionId: sessionId),
          BigCard(pair: pair, session: session),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NextButton(appState: appState),
              SizedBox(width: 10),
              FavoriteButton(appState: appState, icon: icon),
            ],
          ),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  //AQUI MODIFICAMOS ASPECTO Y FUNCIONALIDAD DEL BOTON
  const NextButton({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print('button pressed!');
        appState.getLogin("prueba1", "prueba1");

        appState.getNext();
      },
      child: Text('Next'),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  //AQUI MODIFICAMOS ASPECTO Y FUNCIONALIDAD DEL BOTON
  const FavoriteButton({super.key, required this.appState, required this.icon});

  final MyAppState appState;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        appState.toggleFavorite();
        print(appState.favorites);
      },
      icon: Icon(icon),
      label: Text('Like'),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
    required this.session,
  });

  final WordPair pair;
  final String? session;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'ID DE session: $session',
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
