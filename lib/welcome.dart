import 'package:flutter/material.dart';
import 'main.dart';
import 'inscription.dart';
import 'newproduit.dart';
import 'gererproduit.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _selectedIndex = 0;

  void _itemClique(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewProduit()));
                }, 
                child: PersonaStyledCard(title: "Ajouter un nouveau produit", icon: Icons.add)
              ),
              SizedBox(height: 50),
                ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GererProduit()));
                }, 
                child: PersonaStyledCard(title: "Gérer les produits", icon: Icons.manage_search)
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
                },
                child: PersonaStyledCard(title: "Gérer les commandes", icon: Icons.shopping_cart)
              ),
            ],
          ),
        ),
      ),      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: 'Ajouter un produit'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Compte'),
          
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _itemClique,
      ),
    );
  }
}

class PersonaStyledCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const PersonaStyledCard({Key? key, required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color.fromARGB(255, 23, 42, 214), const Color.fromARGB(255, 202, 23, 23)]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(3, 3))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(2, 2))],
            ),
          ),
        ],
      ),
    );
  }
}