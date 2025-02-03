import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'insription.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Icon _coeur = const Icon(Icons.favorite_border, color: Colors.white,);
  bool _likeBool = false;
  int _selectedIndex = 0;
  int currentIndex = 0;
  String _affichage = 'Accueil';
  
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  



  void _likeThis(){
    setState(() {
      if (_likeBool){
        _coeur = Icon(Icons.favorite_border, color: Colors.white,);
        bool _likeBool = false;
      }
      else {
        _coeur = Icon(Icons.favorite, color: Colors.white,);
        bool _likeBool = true;
      }
    });
  }

  void _itemClique(int index){
    setState(() {
      _selectedIndex = index;
      switch(_selectedIndex){
        case 0:
        {
          _affichage = '$_selectedIndex : Accueil';
        }
        break;
      }
      switch(_selectedIndex){
        case 1:
        {
          _affichage = '$_selectedIndex : Compte';
        }
        break;
      }
      switch(_selectedIndex){
        case 2:
        {
          _affichage = '$_selectedIndex :  Enregistrements';
        }
        break;
      }

    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(onPressed: _likeThis, icon: _coeur)
        ],
        backgroundColor: const Color.fromARGB(255, 58, 136, 21),
        ),
       drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Accueil'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Profil'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Enregistrements'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: _likeThis,
          tooltip: 'Like',
          child: const Icon(Icons.star),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('../assets/images/zeldatp.jpg',
              width: 450,
              height: 500,),
               Image.network('https://www.yourdecoration.fr/cdn/shop/files/pyramid-pp33561-the-legend-of-zelda-majoras-mask-affiche-61x91-5cm_3b8ee742-72a4-4351-aeff-ff4c739e19b2_500x.jpg?v=1731957899',
              width: 200,
               height: 300,),
              Text(_affichage),
            ],
          ),
        ),



        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Compte',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Enregistrements',
            ),
          ],
          currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _itemClique,
        ),
    );
  }
}



