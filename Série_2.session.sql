


-- 1 - Création des tables

CREATE TABLE catégories(
    catégorie_id SERIAL PRIMARY KEY,
    nom TEXT UNIQUE NOT NULL CHECK(LENGTH(nom) <= 50)
);

CREATE TABLE produits(
    produit_id SERIAL PRIMARY KEY,
    nom TEXT NOT NULL CHECK(LENGTH(nom) <= 100),
    prix NUMERIC(10, 2) CHECK(prix > 0) NOT NULL,
    id_categorie INTEGER,
        CONSTRAINT fk_id_categorie_produits
        FOREIGN KEY(id_categorie) REFERENCES catégories(catégorie_id) 
        ON DELETE CASCADE
);

CREATE TABLE clients(
    client_id SERIAL PRIMARY KEY,
    nom TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    ville TEXT NOT NULL,
    date_inscription DATE DEFAULT CURRENT_DATE--J'ai du faire des recherches pour mettre la par defaut aujourd'hui 
);--Et aussi j'avais un peu douté entre DATE et TIMESTAMPTZ pour date_inscription mais comme c'est pour l'inscription et non une commandes j'ai choisi DATE

CREATE TABLE commandes(
    commande_id SERIAL PRIMARY KEY,
    id_client INTEGER,
        CONSTRAINT fk_id_client_commandes
        FOREIGN KEY (id_client) REFERENCES clients(client_id) 
        ON DELETE SET NULL,
    date_commande TIMESTAMPTZ DEFAULT CURRENT_DATE
);

CREATE TABLE lignes_commande(
    ligne_commande_id SERIAL PRIMARY KEY,
    id_commande INTEGER,
        CONSTRAINT fk_id_commande_lignes_commande
        FOREIGN KEY (id_commande) REFERENCES commandes(commande_id)
        ON DELETE CASCADE,
    id_produit INTEGER,
        CONSTRAINT id_produit_lignes_commande
        FOREIGN KEY (id_produit) REFERENCES produits(produit_id)
        ON DELETE SET NULL,
    quantite INTEGER CHECK(quantite > 0) NOT NULL,
    prix_unitaire NUMERIC(10, 2) CHECK(prix_unitaire > 0) NOT NULL
);

CREATE OR REPLACE FUNCTION figer_prix_unitaire()
RETURNS TRIGGER AS $$
BEGIN
    -- On va chercher le prix dans la table produits et on l'assigne à la ligne de commande
    SELECT prix INTO NEW.prix_unitaire 
    FROM produits 
    WHERE produit_id = NEW.id_produit;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_figer_prix
BEFORE INSERT ON lignes_commande
FOR EACH ROW
EXECUTE FUNCTION figer_prix_unitaire();

--Ce pendant pour figer le prix_unitaire j'ai vu le code après quelques recherches mais j'ai pas trop compris aussi revient là-dessus avec des explications et exemples très claires 


-- 2 - Insertion de données

SELECT * from catégories;

INSERT INTO catégories (nom)
VALUES
    ('Électronique'),
    ('Vêtements'),
    ('Maison');

SELECT * from produits;

INSERT INTO produits (nom, prix, id_categorie)
VALUES
    ('Laptop HP', 200000, 1),
    ('Imprimante', 50000, 1),
    ('Pull', 5000, 2),
    ('Pantalon', 7000, 2),
    ('Chambre à couché', 2000000, 3);


SELECT * from lignes_commande;

INSERT INTO clients (nom, email, ville)
VALUES
    ('Mahmoud', 'mahmoud@gmail.com', 'Dahra'),
    ('Abdou', 'abdou@gmail.com', 'Saint Louis'),
    ('Cheikhe', 'cheikhe@gmail.com', 'Louga');

SELECT * from commandes;


INSERT INTO commandes (id_client)
VALUES
    (1),
    (2),
    (3)



SELECT * from lignes_commande;


INSERT INTO lignes_commande (id_commande, id_produit, quantite)
VALUES
    (1, 1, 2),
    (2, 4, 3),
    (3, 5, 1)


-- 3 - Requêtes d'analyse

-- 3.1 : 

SELECT COALESCE(cl.nom, 'Client supprimé'), 
    c.date_commande, 
    COUNT(lc.id_produit) as nbr_produits, 
    SUM(lc.quantite*lc.prix_unitaire) as total_commandes
from clients cl
LEFT JOIN commandes c ON cl.client_id = c.id_client
LEFT JOIN lignes_commande lc ON  c.commande_id = lc.id_commande
GROUP BY cl.nom, c.date_commande--correction c.date_commande Problème : Si un client a deux commandes le même jour, elles seront fusionnées. Il faut grouper par commande_id.
ORDER BY total_commandes DESC;

3.2 : 

--Ajout de nouveau clients sans commandes
INSERT INTO clients (nom, email, ville)
VALUES
    ('Fatou', 'fatou@gmail.com', 'Dakar'),
    ('Bineta', 'bineta@gmail.com', 'Linguére');

SELECT * FROM clients;--Vérification de l'insertion

SELECT cl.nom
from clients cl
LEFT JOIN commandes c ON cl.client_id = c.id_client
WHERE c.commande_id IS NULL;


3.3 : 

SELECT P.nom,
    ca.nom,
    COUNT(p.id_categorie) as nbr_commande,
    SUM(lc.quantite),
    SUM(lc.quantite*lc.prix_unitaire) as chiffre_affaires
FROM produits p  
JOIN catégories ca ON p.id_categorie = ca.catégorie_id
JOIN lignes_commande lc ON p.produit_id = lc.ligne_commande_id
GROUP BY p.nom, ca.nom

"""correction
SELECT 
    p.nom as produit,
    ca.nom as categorie,
    COUNT(lc.id_produit) as nbr_commandes,
    SUM(lc.quantite) as quantite_totale,
    SUM(lc.quantite * lc.prix_unitaire) as chiffre_affaires
FROM produits p  
JOIN catégories ca ON p.id_categorie = ca.catégorie_id
JOIN lignes_commande lc ON p.produit_id = lc.id_produit  -- ✅ Correction
GROUP BY p.nom, ca.nom;"""

-- 3.4 : 
SELECT * FROM lignes_commande

SELECT cl.nom,
    SUM(lc.quantite*lc.prix_unitaire) as total_depense
FROM clients cl
JOIN commandes c ON cl.client_id = c.commande_id
JOIN lignes_commande lc ON c.commande_id = lc.ligne_commande_id
GROUP BY cl.nom
LIMIT 2-- C'est pour vérifier ma requete vu que j'ai un max de 3 clients avec commandes

"""correction
SELECT 
    cl.nom,
    SUM(lc.quantite * lc.prix_unitaire) as total_depense
FROM clients cl
JOIN commandes c ON cl.client_id = c.id_client           -- ✅ cl.client_id = c.id_client
JOIN lignes_commande lc ON c.commande_id = lc.id_commande -- ✅ c.commande_id = lc.id_commande
GROUP BY cl.nom
ORDER BY total_depense DESC
LIMIT 3;
"""

3.5 : 

SELECT 
    TO_CHAR(c.date_commande, 'YYYY-MM') as mois,
    COUNT(DISTINCT c.commande_id) as nbr_commandes,-- DISTINCT pour éviter les doublons
    SUM(lc.quantite*lc.prix_unitaire) as total_ventes
FROM commandes c
JOIN lignes_commande lc ON c.commande_id = lc.ligne_commande_id
GROUP BY mois



-- 🔴 Exercice 4 : Test des contraintes
Teste que tes contraintes fonctionnent correctement :

4.1 : Essaie d'insérer un produit avec un prix négatif → que se passe-t-il ? '

INSERT INTO produits(nom, prix, id_categorie)
VALUES ('Meuble', -500000, 3);
-- Résultat : la nouvelle ligne de la relation « produits » viole la contrainte de vérification « produits_prix_check »

4.2 : Essaie d'insérer un client avec un email déjà utilisé → que se passe-t-il ?'

INSERT INTO clients (nom, email, ville)
VALUES ('Fatima', 'mahmoud@gmail.com', 'Dahra')
-- Résultat : la valeur d'une clé dupliquée rompt la contrainte unique « clients_email_key »

4.3 : Essaie de supprimer une catégorie qui contient des produits → que se passe-t-il (selon ton ON DELETE) ?

DELETE from catégories
WHERE catégorie_id = 1;

SELECT * FROM produits
-- Résultat : la catégorie est supprimé avec les produits qu'il contenait

4.4 : Essaie de supprimer un client qui a des commandes → que se passe-t-il (selon ton ON DELETE) ?

DELETE from clients
WHERE client_id = 1;

-- Résultat : le client est supprimé mais ca commande reste avec null sur l'id_client

4.5 : Essaie de supprimer un produit qui est utilisé dans une ligne de commande → que se passe-t-il (selon ton ON DELETE) ?

SELECT * FROM lignes_commande

Avec : cette requete précédante 
-- avec suppréssion de la catégorie le produit est supprimé et avec cette vérification SELECT * FROM lignes_commande la ligne reste avec null sur i'id_produit tout le reste est inchangé


--Pour les DELETE j'ai du faire des recherches 