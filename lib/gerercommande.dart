import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GererCommandes extends StatefulWidget {
  const GererCommandes({super.key});

  @override
  State<GererCommandes> createState() => _GererCommandesState();
}

class _GererCommandesState extends State<GererCommandes> {
  List<dynamic> _commandes = [];

  static const personaBlue = Color(0xFF0D1B2A);
  static const personaRed = Color(0xFFD90429);
  static const personaWhite = Color(0xFFF8F9FA);

  Future<void> _loadCommandes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/commande'));
    if (response.statusCode == 200) {
      setState(() {
        _commandes = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de chargement des commandes')),
      );
    }
  }

  Future<void> _validerCommande(int id) async {
    final commande = _commandes.firstWhere((c) => c['id'] == id);

    if (commande['etat'].toString().toLowerCase() == 'validée') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Cette commande est déjà validée.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/commandes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'etat': 2}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Commande validée.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadCommandes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la validation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _supprimerCommande(int id) async {
    final response =
        await http.delete(Uri.parse('http://10.0.2.2:3000/commandes/$id'));
    if (response.statusCode == 200) {
      _loadCommandes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: personaBlue,
      appBar: AppBar(
        backgroundColor: personaBlue,
        title: const Text(
          'Gérer les commandes',
          style: TextStyle(
            color: personaWhite,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _commandes.length,
        itemBuilder: (context, index) {
          var commande = _commandes[index];
          final rawDate = commande['dateCommande'];
          String formattedDate = 'Date inconnue';

          if (rawDate != null) {
            try {
              final date = DateTime.parse(rawDate);
              formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
            } catch (_) {}
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: personaWhite.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                'Commande n°${commande['id']} - ${commande['client']}',
                style: const TextStyle(
                  color: personaWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$formattedDate\nTotal : ${commande['total']}€ | État : ${commande['etat']}',
                    style: TextStyle(
                      color: personaWhite.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (commande['produits'] != null)
                    ...List<Widget>.from(
                        commande['produits'].map<Widget>((produit) {
                      return Text(
                        '- ${produit['nom']} x${produit['quantite']}',
                        style: TextStyle(
                          color: personaWhite.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      );
                    })),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _validerCommande(commande['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: personaRed),
                    onPressed: () => _supprimerCommande(commande['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
