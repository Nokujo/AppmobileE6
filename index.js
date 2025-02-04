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
  host: '10.51.7.100', // Remplacez par l'IP de votre serveur MySQL
  user: 'mustaphadmin',         // Nom d'utilisateur de la base de données
  password: '1230',     // Mot de passe de la base de données
  database: 'site commerce'            // Nom de la base de données
});

// Connexion à MySQL
db.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à MySQL:', err);
    return;
  }
  console.log('Connecté à la base de données MySQL');
});



// Endpoint pour récupérer toutes les nations
app.get('/produits', (req, res) => {
  const sql = 'SELECT * FROM produits';
  db.query(sql, (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(results);
  });
});

app.get('/produits/:nom', (req, res) => {
    // Capture le paramètre 'nom' de l'URL
    const nom = '%'+req.params.nom+'%';
    // Crée la requête SQL avec un paramètre pour le nom
    const sql = 'SELECT * FROM produits WHERE nom LIKE ?';
    db.query(sql, [nom], (err, results) => {
    if (err) {
    return res.status(500).send(err);
    }
    if (results.length === 0) {
    // Si aucun produit n'est trouvée, renvoyer une erreur 404
    return res.status(404).json({ message: 'Produits non trouvés' });
    }
    // Si des résultats sont trouvés, renvoyer les données
    res.json(results);
    });
    })

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

// Démarrage du serveur
app.listen(port, () => {
  console.log(`Serveur API en écoute sur http://localhost:${port}`);
});
