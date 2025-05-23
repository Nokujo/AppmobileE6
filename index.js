require('dotenv').config();

const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt'); // tu peux l’utiliser + tard
const cors = require('cors');

const app = express();
const port = 3000;


app.use(cors());
app.use(bodyParser.json());

// connexion bdd
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
  console.log('✅ Connecté à la base de données MySQL');
});


// connexion
app.post('/login', (req, res) => {
  const { nuser, password } = req.body;

  const sql = 'SELECT * FROM utilisateur WHERE idRole= 1 AND nuser = ? OR email = ? LIMIT 1';
  db.query(sql, [nuser, nuser], (err, results) => {
    if (err) return res.status(500).send('Erreur serveur');
    if (results.length === 0) return res.status(401).send('Utilisateur non trouvé');

    const utilisateur = results[0]; 
    const hash = utilisateur.password.replace(/^\$2y\$/, '$2b$'); 

    bcrypt.compare(password, hash, (err, result) => {
      console.log("Résultat bcrypt :", result);
      if (err) return res.status(500).send('Erreur serveur lors du hash');
      if (!result) return res.status(401).send('Mot de passe incorrect');

      return res.status(200).json({ message: 'Connexion réussie', utilisateur });
    });
  });
});



// Lister les utilisateurs
// Après : ne lister que les admins (idRole = 1)
app.get('/user', (req, res) => {
  db.query(
    'SELECT * FROM utilisateur WHERE idRole = ?',
    [1],
    (err, results) => {
      if (err) return res.status(500).send(err);
      res.json(results);
    }
  );
});



// Ajouter un produit
app.post('/produits', (req, res) => {
  const { nom, description, prix, quantite, img } = req.body;

  const sql = 'INSERT INTO produits (nom, description, prix, img, quantite) VALUES (?, ?, ?, ?, ?)';
  db.query(sql, [nom, description, prix, img, quantite], (err, result) => {
    if (err) return res.status(500).send(err);

    res.json({
      id: result.insertId,
      nom,
      description,
      prix,
      quantite,
      img
    });
  });
});

// ---------------------------
// Lister tous les produits
app.get('/produits', (req, res) => {
  db.query('SELECT * FROM produits', (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// ---------------------------
// Récupérer un produit par ID
app.get('/produits/:id', (req, res) => {
  db.query('SELECT * FROM produits WHERE id = ?', [req.params.id], (err, results) => {
    if (err) return res.status(500).send(err);
    if (results.length === 0) return res.status(404).json({ message: 'Produit non trouvé' });
    res.json(results[0]);
  });
});

// ---------------------------
// Modifier un produit
app.put('/produits/:id', (req, res) => {
  const { nom, description, prix, quantite, img } = req.body;

  const sql = 'UPDATE produits SET nom = ?, description = ?, prix = ?, quantite = ?, img = ? WHERE id = ?';
  db.query(sql, [nom, description, prix, quantite, img, req.params.id], (err) => {
    if (err) return res.status(500).send(err);
    res.json({ message: 'Produit mis à jour avec succès' });
  });
});

// ---------------------------
// Supprimer un produit

app.delete('/produits/:id', (req, res) => {
  db.query('DELETE FROM produits WHERE id = ?', [req.params.id], (err, result) => {
    if (err) return res.status(500).send(err);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }
    
    res.json({ message: 'Produit supprimé avec succès' });
  });
});



app.get('/commande', (req, res) => {
  const sql = `
    SELECT 
      c.id AS commande_id,
      c.dateCommande,
      CONCAT(u.prenom, ' ', u.nom) AS client,
      c.montant AS total,
      e.libelle AS etat,
      p.nom AS produit_nom,
      comp.quantite AS produit_quantite
    FROM commande c
    JOIN utilisateur u ON c.idUtilisateur = u.id
    JOIN etat e ON c.idEtat = e.id
    JOIN composer comp ON comp.idCommande = c.id
    JOIN produits p ON comp.idProduit = p.id
  `;

  db.query(sql, (err, results) => {
    if (err) return res.status(500).send(err);

    const commandes = {};

    for (const row of results) {
      const id = row.commande_id;
      if (!commandes[id]) {
        commandes[id] = {
          id: id,
          client: row.client,
          total: row.total,
          etat: row.etat,
          dateCommande: row.dateCommande,
          produits: [],
        };
      }
      commandes[id].produits.push({
        nom: row.produit_nom,
        quantite: row.produit_quantite,
      });
    }

    res.json(Object.values(commandes));
  });
});


app.put('/commande/:id', (req, res) => {
  const { idEtat } = req.body;

  db.query(
    'UPDATE commande SET idEtat = ? WHERE id = ?',
    [idEtat, req.params.id],
    (err) => {
      if (err) return res.status(500).send(err);
      res.json({ message: 'Commande mise à jour' });
    }
  );
});

app.delete('/commande/:id', (req, res) => {
  db.query('DELETE FROM commande WHERE id = ?', [req.params.id], (err) => {
    if (err) return res.status(500).send(err);
    res.json({ message: 'Commande supprimée' });
  });
});

// Lancer le serveur
app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Serveur en écoute sur http://localhost:${port}`);
});
