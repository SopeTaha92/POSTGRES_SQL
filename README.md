


📝 Nouvelle série d'exercices – Avec les bonnes pratiques
Cette série va intégrer tout ce qu'on a vu :

Les types de données appropriés

Les contraintes nommées

Les clés étrangères avec ON DELETE explicite

Les jointures et agrégations

🟢 Exercice 1 : Création d'une base "Boutique" (version expert)
Crée une base de données pour une boutique avec les tables suivantes, en utilisant les bonnes pratiques (contraintes nommées, types adaptés, ON DELETE explicite) :

Table 1 : catégories

id : clé primaire auto-incrémentée

nom : obligatoire, unique, max 50 caractères

Table 2 : produits

id : clé primaire auto-incrémentée

nom : obligatoire, max 100 caractères

prix : obligatoire, positif, 2 décimales

categorie_id : référence vers catégories

Si une catégorie est supprimée, le produit doit être supprimé aussi

Table 3 : clients

id : clé primaire auto-incrémentée

nom : obligatoire

email : obligatoire, unique

ville : obligatoire

date_inscription : date par défaut = aujourd'hui

Table 4 : commandes

id : clé primaire auto-incrémentée

client_id : référence vers clients

Si un client est supprimé, on veut garder la commande mais sans client

date_commande : date par défaut = aujourd'hui

Table 5 : lignes_commande

id : clé primaire auto-incrémentée

commande_id : référence vers commandes

Si une commande est supprimée, ses lignes doivent être supprimées

produit_id : référence vers produits

Si un produit est supprimé, on ne veut pas pouvoir supprimer une ligne de commande qui le contient (protection)

quantite : obligatoire, positive

prix_unitaire : obligatoire, positif, 2 décimales (figé au moment de l'achat)

🟡 Exercice 2 : Insertion de données
Insère des données cohérentes dans toutes les tables :

Au moins 3 catégories (ex: "Électronique", "Vêtements", "Maison")

Au moins 5 produits répartis dans ces catégories

Au moins 3 clients

Au moins 2 commandes avec des lignes de commande

🟠 Exercice 3 : Requêtes d'analyse
Écris les requêtes suivantes :

3.1 : Affiche toutes les commandes avec :

Le nom du client (si le client existe, sinon "Client supprimé")

La date de commande

Le nombre total de produits dans la commande

Le montant total de la commande

3.2 : Affiche les clients qui n'ont jamais commandé

3.3 : Affiche pour chaque produit :

Son nom

Sa catégorie

Le nombre de fois qu'il a été commandé

Le chiffre d'affaires total généré (quantité × prix_unitaire)

3.4 : Affiche le top 3 des clients par montant total dépensé (nom, total dépensé)

3.5 : Affiche pour chaque mois (format "YYYY-MM") :

Le nombre de commandes

Le chiffre d'affaires total

🔴 Exercice 4 : Test des contraintes
Teste que tes contraintes fonctionnent correctement :

4.1 : Essaie d'insérer un produit avec un prix négatif → que se passe-t-il ?

4.2 : Essaie d'insérer un client avec un email déjà utilisé → que se passe-t-il ?

4.3 : Essaie de supprimer une catégorie qui contient des produits → que se passe-t-il (selon ton ON DELETE) ?

4.4 : Essaie de supprimer un client qui a des commandes → que se passe-t-il (selon ton ON DELETE) ?

4.5 : Essaie de supprimer un produit qui est utilisé dans une ligne de commande → que se passe-t-il (selon ton ON DELETE) ?

📋 Comment me rendre tes réponses
Pour chaque exercice, donne-moi :

Le code SQL que tu as écrit

Les résultats obtenus

Si tu as rencontré des difficultés, explique-les