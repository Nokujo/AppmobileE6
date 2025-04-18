import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProduitsPage extends StatefulWidget {
  const ProduitsPage({super.key, required this.title});
  final String title;

  @override
  State<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  final TextEditingController _produitsController = TextEditingController();
  List<Produits> _produits = [];
  final bool enabled = true;

  Future<void> _searchProduits(String query) async {
    final url = Uri.parse('http://10.0.2.2:3000/produits/$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _produits =
            data.map((produits) => Produits.fromJson(produits)).toList();
      });
    } else {
      print('Erreur : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color.fromARGB(255, 109, 31, 139),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _produitsController,
              decoration: const InputDecoration(
                  labelText: 'Recherche dans le Velvet Room'),
              onSubmitted: (value) {
                _searchProduits(value);
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _produits.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_produits[index].nom ?? "Nom inconnu"),
                    subtitle: Text(_produits[index].description ??
                        "Description non disponible"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GestionStocksPage extends StatefulWidget {
  const GestionStocksPage({super.key});

  @override
  State<GestionStocksPage> createState() => _GestionStocksPageState();
}

class _GestionStocksPageState extends State<GestionStocksPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Stock> _stocks = [];

  Future<void> _searchStock(String query) async {
    final List<Stock> allStocks = [
      Stock(name: 'Produit 1', quantity: 50),
      Stock(name: 'Produit 2', quantity: 30),
      Stock(name: 'Produit 3', quantity: 10),
    ];

    setState(() {
      _stocks = allStocks
          .where(
              (stock) => stock.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (value) {
                _searchStock(value);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _stocks.isNotEmpty
                  ? ListView.builder(
                      itemCount: _stocks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.inventory),
                          title: Text(_stocks[index].name),
                          subtitle:
                              Text('Quantité : ${_stocks[index].quantity}'),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Aucun produit trouvé.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Stock {
  final String name;
  final int quantity;

  Stock({required this.name, required this.quantity});
}

class Produits {
  String? nom;
  String? description;

  Produits({this.nom, this.description});

  factory Produits.fromJson(Map<String, dynamic> json) {
    return Produits(
      nom: json['nom'],
      description: json['description'],
    );
  }
}
