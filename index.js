require('dotenv').config();

const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(cors()); // Autorise les requêtes cross-origin
app.use(bodyParser.json()); // Parse le JSON

// Connexion à la base de données
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

db.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à MySQL :', err);
    return;
  }
  console.log('Connecté à la base de données MySQL');
});

// Création utilisateur
app.post('/user', async (req, res) => {
  const { nom, prenom, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const sql = 'INSERT INTO utilisateur (nom, prenom, password) VALUES (?, ?, ?)';
    db.query(sql, [nom, prenom, hashedPassword], (err, result) => {
      if (err) return res.status(500).send(err);
      res.json({ id: result.insertId, nom, prenom });
    });
  } catch {
    res.status(500).send('Erreur lors du hashage du mot de passe');
  }
});

// Liste des utilisateurs
app.get('/user', (req, res) => {
  const sql = 'SELECT * FROM utilisateur';
  db.query(sql, (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// Connexion utilisateur
app.post('/login', (req, res) => {
  const { nom, password } = req.body;

  if (!nom || !password) {
    return res.status(400).json({ message: 'Champs manquants' });
  }

  const sql = 'SELECT * FROM utilisateur WHERE nom = ?';
  db.query(sql, [nom], (err, results) => {
    if (err) return res.status(500).send(err);
    if (results.length === 0) {
      return res.status(401).json({ message: 'Nom ou mot de passe incorrect' });
    }

    const utilisateur = results[0];
    bcrypt.compare(password, utilisateur.password, (err, result) => {
      if (err) return res.status(500).send(err);
      if (!result) return res.status(401).json({ message: 'Nom ou mot de passe incorrect' });

      res.json({ message: 'Connexion réussie', utilisateur });
    });
  });
});


// Ajouter un produit
app.post('/produits', (req, res) => {
  const { nom, description, prix, quantite } = req.body;
  const sql = 'INSERT INTO produits (nom, description, prix, quantite) VALUES (?, ?, ?, ?)';
  db.query(sql, [nom, description, prix, quantite], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ id: result.insertId, nom, description, prix, quantite });
  });
});

// Obtenir tous les produits
app.get('/produits', (req, res) => {
  const sql = 'SELECT * FROM produits';
  db.query(sql, (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// Obtenir un produit par ID
app.get('/produits/:id', (req, res) => {
  const sql = 'SELECT * FROM produits WHERE id = ?';
  db.query(sql, [req.params.id], (err, results) => {
    if (err) return res.status(500).send(err);
    if (results.length === 0) return res.status(404).json({ message: 'Produit non trouvé' });
    res.json(results[0]);
  });
});

// Modifier un produit
app.put('/produits/:id', (req, res) => {
  const { nom, description, prix, quantite } = req.body;
  const sql = 'UPDATE produits SET nom = ?, description = ?, prix = ?, quantite = ? WHERE id = ?';
  db.query(sql, [nom, description, prix, quantite, req.params.id], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: 'Produit mis à jour avec succès' });
  });
});

// ============================
// ===== Lancer le serveur ====
app.listen(port, '0.0.0.0', () => {
  console.log(`Serveur API en écoute sur http://localhost:${port}`);
});
