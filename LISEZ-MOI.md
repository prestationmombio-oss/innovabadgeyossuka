# InnovaBadge — mise en route (≈ 20 min)

**Produit InnovaData** · pointage scolaire par badge QR · fonctionne en ligne ET hors ligne.

## 1. Base de données (Supabase, gratuit pour démarrer)
1. Créez un projet sur https://supabase.com
2. **SQL Editor** → collez le contenu de `schema.sql` → *Run*.
3. **Authentication → Users → Add user** : créez le compte du personnel (email + mot de passe, cochez *Auto confirm*).
4. **Settings → API** : copiez *Project URL* et la clé **anon public**.
5. Collez-les dans `config.js`. (Ne mettez JAMAIS la clé `service_role`.)

## 2. Déploiement (HTTPS obligatoire pour la caméra)
Glissez-déposez le dossier sur **Netlify Drop** (app.netlify.com/drop), Cloudflare Pages ou Vercel. Vous obtenez une adresse https://…

## 3. Installation sur les téléphones
1. Ouvrez l’adresse dans Chrome (Android) ou Safari (iPhone) **avec internet**.
2. Connectez-vous (une seule fois), puis *Ajouter à l’écran d’accueil*.
3. Dès lors l’application s’ouvre sans internet.

## 4. Utilisation
- **Élèves** : collez la liste Excel `matricule;nom;prénom;classe` → *Importer*.
- **Badges** : choisissez la classe → *Imprimer* (format carte 86×54 mm).
- **Scanner** : *Activer la caméra*, présenter le badge. 1er passage = Entrée, 2e = Sortie.
- Hors ligne : les passages sont gardés sur le téléphone (⏳) et envoyés automatiquement au retour du réseau, sans doublons.
- **Aujourd’hui** : présents, passages, en attente de synchro.

## Sécurité
Chaque QR contient un jeton aléatoire propre à l’élève (non devinable). L’accès aux données exige une connexion du personnel.

## Si la caméra ne démarre pas
Vérifier : adresse en https, autorisation caméra accordée au navigateur. Sinon utiliser la saisie manuelle du matricule.
