import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'welcome.dart';

class NewProduit extends StatefulWidget {
  const NewProduit({super.key});

  @override
  State<NewProduit> createState() => _NewProduitState();
}

class _NewProduitState extends State<NewProduit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();

  // Persona theme colors
  static const personaBlue = Color(0xFF0D1B2A);
  static const personaRed = Color(0xFFD90429);
  static const personaWhite = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: personaBlue,
      appBar: AppBar(
        backgroundColor: personaBlue,
        title: const Text(
          'Ajouter des produits',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final response = await http.post(
                          Uri.parse('http://10.0.2.2:3000/produits'),
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
                              content: Text('Produit ajouté avec succès'),
                              backgroundColor: personaRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          // Clear form after successful submission
                          _nomController.clear();
                          _prixController.clear();
                          _descriptionController.clear();
                          _quantiteController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: ${response.body}'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur de connexion: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: personaRed,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'CRÉER',
                    style: TextStyle(
                      color: personaWhite,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
