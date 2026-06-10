# Tiny Act

Tiny Act est une application Rails qui aide l'utilisateur à choisir et réaliser de petites activités adaptées à son humeur, son lieu, sa durée disponible et ses centres d'intérêt. Chaque activité terminée rapporte de l'XP, fait progresser l'utilisateur par domaine et permet de débloquer des meubles pour personnaliser une room partageable.

## Fonctionnalités principales

- Recommandations d'activités selon le mood, la localisation, la durée et les centres d'intérêt sélectionnés.
- Sessions d'activité avec statuts (`selecting`, `preview`, `in_progress`, `paused`, `finished`, `abandoned`), timer, pause/reprise et abandon.
- Système d'XP attribuée à la fin d'une session terminée.
- Progression par centre d'intérêt via `UserInterestProgress`.
- Déblocage de meubles selon l'XP gagnée dans chaque centre d'intérêt.
- Room personnelle personnalisable sur une grille 5 x 5.
- Inventaire de meubles disponibles selon les déblocages de l'utilisateur.
- Rooms sociales classées par nombre de likes, avec possibilité d'aimer ou retirer son like.
- Historique des activités terminées avec XP gagnée.
- Comptes utilisateur avec Devise et choix d'avatar.
- Expériences d'activité spécialisées : quiz culture, quiz code, langues, mélodies, sport guidé, dessin, photo, bien-être et productivité selon les données seedées.
- Support PWA basique via manifest et service worker.

## Stack technique

- Ruby on Rails 8.1
- PostgreSQL
- Devise pour l'authentification
- Hotwire / Turbo
- Stimulus via Importmap
- SCSS, Bootstrap 5, Font Awesome
- Solid Cache, Solid Queue et Solid Cable
- Propshaft / Sprockets pour les assets
- Roo pour l'import de données tabulaires
- Tone.js, chargé via Importmap, pour les activités musicales

Le projet ne contient pas de `package.json` au moment de cette documentation : l'installation JavaScript passe donc par Importmap, sans étape Yarn ou NPM obligatoire.

## Installation locale

Prérequis :

- Ruby compatible avec Rails 8.1
- PostgreSQL lancé localement
- Bundler

Installation :

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```

L'application est ensuite disponible sur :

```text
http://localhost:3000
```

Si vous utilisez le script de développement Rails :

```bash
bin/dev
```

## Seeds utiles

La seed principale est [db/seeds.rb](db/seeds.rb). Elle initialise notamment :

- les moods : `En forme`, `Mitigé`, `À plat` ;
- les durées : 5, 15 et 30 minutes ;
- les lieux : `Maison`, `Extérieur`, `Bureau`, `N'importe où` ;
- les centres d'intérêt : sport, bien-être, photo, dessin, langues, culture, productivité, code et musique ;
- les activités principales et les activités importées depuis CSV ;
- les questions de culture et de code ;
- les items de langue ;
- les mélodies depuis [db/seeds_melodies.rb](db/seeds_melodies.rb) ;
- les meubles associés aux centres d'intérêt ;
- des utilisateurs de démonstration et leurs likes sociaux.

Des tâches Rake importent les données depuis [db/data](db/data), par exemple :

```bash
bin/rails language_activities:import
bin/rails sport_activities:import
bin/rails productivite_activities:import
bin/rails photo_activities:import
bin/rails bien_etre_activities:import
bin/rails dessin_activities:import
bin/rails culture_questions:import_csv
bin/rails code_questions:import_csv
```

Le fichier [db/seeds/room.rb](db/seeds/room.rb) contient une seed de meubles plus courte. La seed complète utilisée par défaut reste [db/seeds.rb](db/seeds.rb).

## Comptes de test

La seed crée plusieurs utilisateurs de démonstration avec le mot de passe :

```text
123456
```

Exemples :

- `jc.demo@example.com`
- `tibo.demo@example.com`
- `david.demo@example.com`
- `dina.demo@example.com`
- `emma.demo@example.com`
- `noah.demo@example.com`
- `lou.demo@example.com`
- `hugo.demo@example.com`
- `zoe.demo@example.com`
- `tom.demo@example.com`

Elle crée aussi 50 comptes `lambda`, de `lambda1.demo@example.com` à `lambda50.demo@example.com`, avec le même mot de passe.

## Structure importante du projet

```text
app/controllers/
  activity_sessions_controller.rb   # choix, progression et fin des sessions
  activities_controller.rb           # affichage d'une activité guidée
  rooms_controller.rb                # room personnelle et galerie sociale
  room_furnitures_controller.rb      # ajout, déplacement et suppression de meubles
  room_likes_controller.rb           # likes des rooms
  user_interests_controller.rb       # centres d'intérêt utilisateur
  users_controller.rb                # profil, avatar, stats et progression

app/models/
  activity.rb
  activity_session.rb
  furniture.rb
  room.rb
  room_furniture.rb
  room_like.rb
  user.rb
  user_interest.rb
  user_interest_progress.rb

app/services/
  xp_calculator.rb                   # calcul et attribution de l'XP
  activity_loaders/                  # contexte des activités spécialisées

app/javascript/controllers/
  *_controller.js                    # interactions Stimulus : timers, room, quiz, inventaire, etc.

app/assets/stylesheets/
  pages/                             # styles des pages principales
  components/                        # styles des composants UI

db/
  schema.rb                          # structure de la base
  seeds.rb                           # données de démonstration principales
  data/                              # CSV d'activités et de questions
```

## Routes principales

- `GET /` : création d'une nouvelle session d'activité.
- `GET /activity_sessions/location` : choix du lieu après le mood.
- `GET /activity_sessions/duration` : choix de la durée.
- `POST /activity_sessions` : création d'une session avec activité recommandée.
- `GET /activity_sessions/:id` : recommandations ou résumé de session.
- `PATCH /activity_sessions/:id/start` : démarrage du timer.
- `PATCH /activity_sessions/:id/progress` : mise à jour de la progression.
- `PATCH /activity_sessions/:id/pause` et `PATCH /activity_sessions/:id/resume` : pause et reprise.
- `PATCH /activity_sessions/:id/abandon` : abandon d'une session.
- `GET /activities/:id` : affichage de l'activité à réaliser.
- `GET /user` : profil utilisateur.
- `GET /user_interests` : sélection des centres d'intérêt.
- `GET /rooms` : galerie sociale des rooms.
- `GET /rooms/:id` : room de l'utilisateur connecté.
- `POST /rooms/:room_id/like` et `DELETE /rooms/:room_id/like` : likes sociaux.

## Logique métier

### Recommandations d'activités

Une session est créée à partir des critères choisis :

- mood ;
- lieu, avec inclusion des activités disponibles `N'importe où` ;
- durée ;
- centres d'intérêt de l'utilisateur ;
- activités actives uniquement.

La page de session propose ensuite jusqu'à 3 recommandations, en sélectionnant au plus une activité par centre d'intérêt compatible. Les IDs recommandés sont stockés dans `candidate_activity_ids` pour conserver l'ordre de proposition.

Certaines règles temporaires filtrent les types d'activités selon la durée. Par exemple, les activités `llm_chat` sont exclues des durées actuellement gérées, et certains exercices de langue ou quiz code sont exclus de durées spécifiques.

### Calcul de l'XP

Le calcul est centralisé dans `XpCalculator`.

Base par durée :

- 5 minutes : 10 XP
- 15 minutes : 22 XP
- 30 minutes : 40 XP
- autre durée : 10 XP

Multiplicateur par mood :

- `À plat` : x1.3
- `Bof` ou `Mitigé` : x1.15
- `En forme` : x1.0
- autre mood : x1.0

Le résultat est arrondi. L'XP est attribuée une seule fois grâce au champ `xp_awarded_at`, puis stockée dans `xp_earned`. La progression par centre d'intérêt est synchronisée dans `user_interest_progresses`.

### Déblocage des meubles

Chaque meuble appartient à un centre d'intérêt et possède un seuil `required_xp`. Lorsqu'une session est terminée :

1. l'application identifie les meubles encore verrouillés pour l'intérêt de l'activité ;
2. elle attribue l'XP de la session ;
3. elle recalcule l'XP totale de l'utilisateur sur cet intérêt ;
4. elle enregistre les nouveaux meubles débloqués dans `newly_unlocked_furniture_ids`.

La notification de déblocage est affichée dans le résumé de session tant que `furniture_unlocks_seen_at` n'a pas été renseigné.

### Room et inventaire

Chaque utilisateur reçoit automatiquement une room à la création du compte. La room utilise une grille 5 x 5 (`Room::GRID_WIDTH` et `Room::GRID_HEIGHT`).

Les meubles disponibles dans l'inventaire sont ceux dont le seuil `required_xp` est inférieur ou égal à l'XP de l'utilisateur dans le centre d'intérêt associé. Les meubles placés sont représentés par `RoomFurniture`, avec :

- position `x` / `y` ;
- profondeur `z` ;
- rotation ;
- dimensions issues du meuble (définis dans la seed).

Le contrôleur vérifie qu'un meuble reste dans la grille et ne chevauche pas un autre meuble avant d'accepter un déplacement.

### Rooms sociales

La galerie sociale liste les rooms avec leurs utilisateurs, meubles et likes. Les rooms sont ordonnées par nombre de likes décroissant. Un utilisateur ne peut liker une room qu'une seule fois grâce à l'unicité `user_id` / `room_id`.

## Commandes utiles

```bash
# Lancer le serveur
bin/rails server

# Console Rails
bin/rails console

# Recréer la base en développement
bin/rails db:drop db:create db:migrate db:seed

# Lancer les tests
bin/rails test

# Lancer un test précis
bin/rails test test/services/xp_calculator_test.rb

# Audit sécurité des gems
bin/bundler-audit

# Analyse statique sécurité
bin/brakeman

# Lint Ruby
bin/rubocop
```

## Notes de développement

- La racine de l'application est `activity_sessions#new`.
- L'application suppose qu'un utilisateur connecté possède une room ; `User` crée une room par défaut après création.
- Les activités spécialisées s'appuient sur des loaders dans `app/services/activity_loaders`.
- Les controllers Stimulus gèrent une grande partie des interactions front : timer, room, inventaire, quiz, canvas de dessin, exercices de langue, activité musicale et notifications.
- Les données seedées sont importantes pour tester l'application : sans moods, durées, lieux, intérêts et activités, les recommandations ne peuvent pas fonctionner correctement.
- Les activités `llm_chat` existent dans les types d'activité mais sont seedées comme inactives dans l'état actuel.
- Il n'y a pas d'étape Yarn/NPM documentée, car aucun `package.json` n'est présent.

## Pistes d'amélioration futures

- Ajouter une contrainte d'unicité en base sur les likes de room pour compléter la validation modèle.
- Clarifier ou séparer les seeds de démonstration et les seeds minimales nécessaires au fonctionnement.
- Ajouter une page d'administration ou des tâches dédiées pour gérer les activités, meubles et questions.
- Rendre la progression quotidienne plus visible avec objectifs, séries et statistiques détaillées.
- Améliorer la gestion des activités inactives ou expérimentales, notamment `llm_chat`.
- Documenter les variables d'environnement si de nouvelles intégrations externes sont ajoutées.
