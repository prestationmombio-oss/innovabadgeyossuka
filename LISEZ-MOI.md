# InnovaBadge v2 — multi-écoles (InnovaData)

## Mise à jour depuis la v1
1. Supabase > SQL Editor : exécutez d'abord `drop view if exists presences_jour; drop table if exists scans, students cascade;`
   (efface les données de test), puis tout le contenu de `schema.sql`.
2. Gardez VOTRE `config.js` (ne le remplacez pas par celui du zip). Redéployez les autres fichiers.
3. Sur les téléphones : rouvrir l'application avec internet (la mise à jour est automatique).

## Créer une nouvelle école (à faire par InnovaData)
1. Supabase > Authentication > Users > Add user (email + mot de passe, cochez Auto Confirm) : compte de la direction.
2. SQL Editor : `select onboard_school('Nom de l''école', 'email-direction@ecole.com');`
3. Compte supplémentaire (agent de sécurité, rôle limité au scan) : créez l'utilisateur, puis
   `select link_user('<id-ecole>', 'agent@ecole.com', 'surveillant');`
   (l'id de l'école est dans la table `schools`).
4. La direction se connecte, puis : Personnes > importer Élèves, Professeurs, Administration > Badges > Imprimer.

## Rôles
- **direction** : tout (tableau de bord, import, badges, scan).
- **surveillant** : scan et liste des passages uniquement.

## Imports (collés depuis Excel)
- Élèves : `matricule;nom;prénom;classe;niveau` (niveau facultatif)
- Professeurs : `matricule;nom;prénom;discipline`
- Administration : `matricule;nom;prénom;fonction`

## Tableau de bord
Par catégorie, sur un jour ou une période : effectif, présents, absents, taux, retards ; détail par niveau puis classe
(élèves), par discipline (professeurs), par fonction (administration). Touchez une ligne pour voir les absents ; bouton
« Copier la liste » (WhatsApp). Un jour compte comme jour d'école s'il y a au moins un pointage ce jour-là.

## Sauvegarde
Bouton « Générer le CSV » du tableau de bord (à faire chaque semaine) + sauvegardes automatiques Supabase (offre Pro).
