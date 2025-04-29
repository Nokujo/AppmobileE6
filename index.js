require('dotenv').config();
const dbHost = process.env.DB_HOST;
const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASSWORD;
const dbName = process.env.DB_NAME;

const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const app = express();
const port = 3000;

// Middleware pour parser le body des requêtes en JSON
app.use(bodyParser.json());

// Configuration de la connexion à MySQL
const db = mysql.createConnection({
  host: dbHost, // Remplacez par l'IP de votre serveur MySQL
  user: dbUser,         // Nom d'utilisateur de la base de données
  password: dbPassword,     // Mot de passe de la base de données
  database: dbName            // Nom de la base de données
});

// Connexion à MySQL
db.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à MySQL:', err);
    return;
  }
  console.log('Connecté à la base de données MySQL');
});


// Endpoint pour ajouter un nouvel utilisateur
app.post('/user', async  (req, res) => {
  const { nom, prenom, email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const sql = 'INSERT INTO `utilisateur` (nom, prenom, email, password) VALUES (?, ?, ?, ?)';
    db.query(sql, [nom, prenom, email, hashedPassword], (err, result) => {
      if (err) {
        return res.status(500).send(err);
      }
      res.json({ 
        id: result.insertId, 
        nom, 
        prenom, 
        email
      });
    });
  } catch (err) {
    res.status(500).send('Erreur lors du hashage du mot de passe');
  }
});

app.get('/user', (req, res) => {
  const sql = 'SELECT * FROM utilisateur';
  db.query(sql, (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(results);
  });
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: '12345689'});
  } 
  const sql = 'SELECT * FROM `utilisateur` WHERE email = ?';
  db.query(sql, [email], async (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    if (results.length === 0) {
      return res.status(401).json({ message: 'Emailt de passe incorrect' });
    }

    const utilisateur = results[0];

    bcrypt.compare(password, utilisateur.password, (err, result) => {
      if (err) {
        return res.status(500).send(err);
      }
      if (!result) {
        return res.status(401).json({ message:'email ou mdp incorrect'});
      }

      res.json({ message: 'Connexion reussite', utilisateur });
    });
  });
});

// Add these endpoints after your existing code but before app.listen()

// Endpoint to add a new product
app.post('/produit', (req, res) => {
  const { nom, description, prix, quantite } = req.body;
  const sql = 'INSERT INTO produit (nom, description, prix, quantite) VALUES (?, ?, ?, ?)';
  
  db.query(sql, [nom, description, prix, quantite], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json({ 
      id: result.insertId,
      nom,
      description, 
      prix,
      quantite
    });
  });
});

// Endpoint to get all products
app.get('/produit', (req, res) => {
  const sql = 'SELECT * FROM produit';
  db.query(sql, (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(results);
  });
});

// Endpoint to get a single product by ID
app.get('/produits/:id', (req, res) => {
  const sql = 'SELECT * FROM produit WHERE id = ?';
  db.query(sql, [req.params.id], (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    if (results.length === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(results[0]);
  });
});

// Endpoint to update a product
app.put('/produits/:id', (req, res) => {
  const { nom, description, prix, image } = req.body;
  const sql = 'UPDATE produit SET nom = ?, description = ?, prix = ?, image = ? WHERE id = ?';
  
  db.query(sql, [nom, description, prix, image, req.params.id], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json({ message: 'Product updated successfully' });
  });
});



// Démarrage du serveur
app.listen(port, () => {
  console.log(`Serveur API en écoute sur http://localhost:${port}`);
});
