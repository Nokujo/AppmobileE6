import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _produitsController = TextEditingController();
  List<Produits> _produits = [];

  Future<void> _searchProduits(String query) async {
    final url = Uri.parse('http://10.0.2.2:3000/produits/$query');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _produits = data.map((produit) => Produits.fromJson(produit)).toList();
      });
    } else {
      print('Erreur : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        backgroundColor: const Color.fromARGB(255, 109, 31, 139),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _produitsController,
              decoration: const InputDecoration(labelText: 'Recherche dans le Velvet Room'),
              onSubmitted: _searchProduits,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: _produits.isNotEmpty
                ? ListView.builder(
                    itemCount: _produits.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_produits[index].nom ?? "Nom inconnu"),
                        subtitle: Text(_produits[index].description ?? "Description non disponible"),
                      );
                    },
                  )
                : const Center(
                    child: Text('Aucun produit trouvé.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
          ),
        ],
      ),
    );
  }
}

class Produits {
  final String? nom;
  final String? description;

  Produits({this.nom, this.description});

  factory Produits.fromJson(Map<String, dynamic> json) {
    return Produits(
      nom: json['nom'],
      description: json['description'],
    );
  }
}