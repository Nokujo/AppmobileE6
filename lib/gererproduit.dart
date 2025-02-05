import 'package:flutter/material.dart';

class GererProduit extends StatefulWidget {
  const GererProduit({Key? key}) : super(key: key);

  @override
  State<GererProduit> createState() => _GererProduitState();
}

class _GererProduitState extends State<GererProduit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
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
                  controller: _quantiteController,
                  label: 'Quantité',
                  icon: Icons.shopping_basket,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Produit ajouté avec succès'),
                          backgroundColor: personaRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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
                    'AJOUTER LE PRODUIT',
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

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }
}