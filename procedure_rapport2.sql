USE CRM2;
GO

IF OBJECT_ID('dbo.sp_Rapport2', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Rapport2;
GO

CREATE PROCEDURE dbo.sp_Rapport2
    @Annee INT
AS
BEGIN
    SELECT
        c.[Année]          AS Annee,
        c.Trimestre,
        c.Mois,
        SUM(v.CA)          AS CA,
        SUM(v.CA - v.COGS) AS Benefice,
        b_agg.BudgetCA
    FROM dbo.Ventes v
    INNER JOIN dbo.Calendrier c ON v.Date = c.Date
    LEFT JOIN (
        SELECT Date, SUM(BudgetCA) AS BudgetCA
        FROM dbo.Budget
        GROUP BY Date
    ) b_agg ON b_agg.Date = c.Date
    WHERE c.[Année] = @Annee
    GROUP BY c.[Année], c.Trimestre, c.Mois, b_agg.BudgetCA
    ORDER BY c.[Année], c.Trimestre, c.Mois;
END;
GO
