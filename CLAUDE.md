# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

Projet SSRS (SQL Server Reporting Services) — examen académique (Pr A. Boly).
Deux rapports à produire : `Rapport_1.rdl` et `Rapport_2.rdl`.
L'outil utilisé est **Visual Studio avec l'extension SSRS Report Designer**, ciblant SSRS2016.

Déploiement local : `http://localhost/reportserver`

## Base de données

- **Serveur** : `WALY\SQLSERVER2025`
- **Base** : `CRM2` (attention : pas `CRM` — la base `CRM` existe aussi mais ne contient pas les bonnes tables)
- **Source de données partagée** : `CRM.rds` (pointe déjà sur CRM2)

### Tables

**`dbo.Calendrier`** — dimension temporelle
| Colonne | Type | Notes |
|---|---|---|
| Date | datetime | clé de jointure avec Ventes |
| Année | int | ex: 2009 |
| Mois | int | 1 à 12 |
| Mois Nom | nvarchar | "Janvier", "Février"... |
| Mois Nom Court | nvarchar | "Jan", "Fev"... |
| Trimestre | nvarchar | "T1", "T2", "T3", "T4" |
| Semestre | nvarchar | "S1", "S2" |

**`dbo.Ventes`** — table de faits
| Colonne | Type | Notes |
|---|---|---|
| ID | int | |
| Date | datetime | clé de jointure avec Calendrier |
| Client No | int | |
| Commercial No | int | |
| Produit | nvarchar | |
| CA | int | Chiffre d'affaires |
| QTY | int | Quantité |
| COGS | int | Coût des marchandises |

**`dbo.Clients`** — dimension clients
| Colonne | Type |
|---|---|
| Client No | int |
| Client Nom | nvarchar |
| Client Ville | nvarchar |
| Type | nvarchar ("Client" ou "Prospect") |

## Pièges importants

1. **Encodage des dates** : dans `Ventes` et `Calendrier`, le champ `Date` n'est PAS une vraie date calendaire. Le composant *jour* encode le *numéro du mois* : `2009-01-02` = Année 2009, Mois 2 (Février). La jointure `Ventes.Date = Calendrier.Date` est correcte grâce à ce même encodage.

2. **Bénéfice n'est pas une colonne** : il se calcule toujours par `CA - COGS`.

3. **Trimestre est une chaîne** : valeurs "T1" à "T4", déjà formatées pour l'affichage.

## Requête de base (Rapport_1 et Rapport_2)

```sql
SELECT
    c.Année,
    c.Trimestre,
    c.Mois,
    SUM(v.CA)           AS CA,
    SUM(v.CA - v.COGS)  AS Benefice
FROM dbo.Ventes v
INNER JOIN dbo.Calendrier c ON v.Date = c.Date
GROUP BY c.Année, c.Trimestre, c.Mois
ORDER BY c.Année, c.Trimestre, c.Mois
```

Valeurs de contrôle vérifiées (2009) :
- Mois 1 → CA = 9 800, Bénéfice = 3 430
- T1 → CA = 37 500, Bénéfice = 12 680
- Total 2009 → CA = 192 500, Bénéfice = 64 280

## Rapports à produire

### Rapport_1 ✅ TERMINÉ

- **Type** : Tableau (pas Matrice) avec groupes de lignes imbriqués et drill-down
- **Structure** : 3 colonnes — `Temps` (fusionnée sur Année/Trimestre/Mois), `CA`, `Bénéfice`
- **Groupes de lignes** : `Année` → `Trimestre` → `Mois` (chacun avec en-tête de groupe)
- **Drill-down** : ligne Trimestre masquée/togglee par cellule Année ; ligne Mois masquée/togglee par cellule Trimestre
- **Totaux** : sous-totaux automatiques via les groupes, Total général en bas
- **Paramètre** : `Annee` (sans accent, Integer, défaut 2009) — sensible à la casse
- **Procédure stockée** : `sp_Rapport1 @Annee INT` dans CRM2
- **Dataset** : `DS_rapport1` — type Procédure stockée, lié à source `CRM`
- **Expressions** : `=SUM(Fields!CA.Value)` et `=SUM(Fields!Benefice.Value)` dans chaque ligne de groupe
- **Piège** : ne pas utiliser une Matrice (donne 3 colonnes séparées) — utiliser un Tableau

### Rapport_2 — "Tableau de bord général"
- **Type** : Matrice SSRS
- **Colonnes** : CA, Bénéfice, % Bénéfice, Réel Vs Budget (avec indicateurs d'icônes)
- **Paramètres** :
  - `Année` → valeur unique
  - `Trimestre` → valeurs multiples
  - `Mois` → valeurs multiples
- **Formule Réel Vs Budget** : `(SUM(CA) - SUM(Budget CA)) / SUM(Budget CA)`
- **Note** : la table Budget n'a pas encore été identifiée dans la base — à vérifier dans `CRM.SAS_Benefice`

## Rendu attendu

- Le dossier du projet SSRS complet
- Un document PDF avec les aperçus des deux rapports
