import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les données JSON
import 'welcome.dart'; 

class GererProduit extends StatefulWidget {
  const GererProduit({super.key});

  @override
  State<GererProduit> createState() => _GererProduitState();
}

class _GererProduitState extends State<GererProduit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Persona theme colors
  static const personaBlue = Color(0xFF0D1B2A);
  static const personaRed = Color(0xFFD90429);
  static const personaWhite = Color(0xFFF8F9FA);

  // Liste des produits
  List<dynamic> _produits = [];

  // Charger les produits depuis l'API
  Future<void> _loadProduits() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/produits'));

    if (response.statusCode == 200) {
      setState(() {
        _produits = json.decode(response.body);
      });
    } else {
      throw Exception('Échec du chargement des produits');
    }
  }

  // Modifier un produit
  Future<void> _modifierProduit(int id) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/produits/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nom': _nomController.text,
        'description': _descriptionController.text,
        'prix': double.parse(_prixController.text),
        'quantite': int.parse(_quantiteController.text),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit mis à jour avec succès'),
          backgroundColor: personaRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadProduits(); // Recharger la liste des produits
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${response.body}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: personaBlue,
      appBar: AppBar(
        backgroundColor: personaBlue,
        title: const Text(
          'Gérer les produits',
          style: TextStyle(
            color: personaWhite,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              personaBlue,
              personaBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: _produits.length,
          itemBuilder: (context, index) {
            var produit = _produits[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: personaWhite.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  produit['nom'],
                  style: const TextStyle(
                    color: personaWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Prix: ${produit['prix']}€ | Quantité: ${produit['quantite']}',
                  style: TextStyle(
                    color: personaWhite.withOpacity(0.7),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: personaRed),
                  onPressed: () {
                    _nomController.text = produit['nom'];
                    _prixController.text = produit['prix'].toString();
                    _quantiteController.text = produit['quantite'].toString();
                    _descriptionController.text = produit['description'];

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: personaBlue,
                          title: const Text(
                            'Modifier le produit',
                            style: TextStyle(
                              color: personaWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  buildPersonaTextField(
                                    controller: _nomController,
                                    label: 'Nom du produit',
                                    icon: Icons.inventory,
                                  ),
                                  const SizedBox(height: 20),
                                  buildPersonaTextField(
                                    controller: _prixController,
                                    label: 'Prix',
                                    icon: Icons.euro,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 20),
                                  buildPersonaTextField(
                                    controller: _descriptionController,
                                    label: 'Description',
                                    icon: Icons.description,
                                  ),
                                  const SizedBox(height: 20),
                                  buildPersonaTextField(
                                    controller: _quantiteController,
                                    label: 'Quantité',
                                    icon: Icons.shopping_basket,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Annuler',
                                style: TextStyle(color: personaWhite),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _modifierProduit(produit['id']);
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: personaRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Sauvegarder',
                                style: TextStyle(
                                  color: personaWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPersonaTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: personaWhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: personaWhite),
        keyboardType: keyboardType,
        maxLines: label == 'Description' ? null : 1,
        minLines: label == 'Description' ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: personaWhite.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: personaRed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est requis';
          }
          return null;
        },
      ),
    );
  }
}
