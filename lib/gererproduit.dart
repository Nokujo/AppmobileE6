import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final TextEditingController _imgController = TextEditingController();

  static const personaBlue = Color(0xFF0D1B2A);
  static const personaRed = Color(0xFFD90429);
  static const personaWhite = Color(0xFFF8F9FA);

  List<dynamic> _produits = [];

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

  Future<void> _modifierProduit(int id) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/produits/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'nom': _nomController.text,
        'description': _descriptionController.text,
        'prix': double.parse(_prixController.text),
        'quantite': int.parse(_quantiteController.text),
        'img': _imgController.text,
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
      _loadProduits();
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

  // 2.1) Appel HTTP DELETE côté Flutter
  Future<void> _supprimerProduit(int id) async {
    // Envoie la requête DELETE à ton API
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/produits/$id'),
    );

    // Si tout s'est bien passé, on affiche un SnackBar de confirmation
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit supprimé avec succès'),
          backgroundColor: personaRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Sinon on affiche l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erreur lors de la suppression (code ${response.statusCode})'),
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
            colors: [personaBlue, personaBlue.withOpacity(0.8)],
          ),
        ),
        child: ListView.builder(
          itemCount: _produits.length,
          itemBuilder: (context, index) {
            final produit = _produits[index];
            return Dismissible(
              key: Key(produit['id'].toString()),
              direction: DismissDirection
                  .startToEnd, // Suppression en swippant vers la droite
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: personaRed,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                // 1) Suppression locale pour l'animation
                setState(() {
                  _produits.removeAt(index);
                });
                // 2) Suppression serveur
                await _supprimerProduit(produit['id']);
              },
              child: Card(
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
                    'Prix: ${produit['prix']}€ | Qté: ${produit['quantite']}',
                    style: TextStyle(color: personaWhite.withOpacity(0.7)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: personaRed),
                    onPressed: () {
                      _nomController.text = produit['nom'];
                      _prixController.text = produit['prix'].toString();
                      _quantiteController.text = produit['quantite'].toString();
                      _descriptionController.text = produit['description'];
                      _imgController.text = produit['img'] ?? '';

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
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
                                    _nomController,
                                    'Nom du produit',
                                    Icons.inventory,
                                  ),
                                  const SizedBox(height: 15),
                                  buildPersonaTextField(
                                    _prixController,
                                    'Prix',
                                    Icons.euro,
                                    TextInputType.number,
                                  ),
                                  const SizedBox(height: 15),
                                  buildPersonaTextField(
                                    _descriptionController,
                                    'Description',
                                    Icons.description,
                                  ),
                                  const SizedBox(height: 15),
                                  buildPersonaTextField(
                                    _quantiteController,
                                    'Quantité',
                                    Icons.shopping_basket,
                                    TextInputType.number,
                                  ),
                                  const SizedBox(height: 15),
                                  buildPersonaTextField(
                                    _imgController,
                                    'URL de l\'image',
                                    Icons.link,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPersonaTextField(
      TextEditingController controller, String label, IconData icon,
      [TextInputType? keyboardType]) {
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
        validator: (value) =>
            value == null || value.isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }
}
