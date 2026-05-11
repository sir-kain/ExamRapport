USE CRM2
GO

CREATE PROCEDURE sp_Rapport1
    @Annee INT
AS
BEGIN
    SELECT
        c.Année,
        c.Trimestre,
        c.Mois,
        SUM(v.CA)          AS CA,
        SUM(v.CA - v.COGS) AS Benefice
    FROM dbo.Ventes v
    INNER JOIN dbo.Calendrier c ON v.Date = c.Date
    WHERE c.Année = @Annee
    GROUP BY c.Année, c.Trimestre, c.Mois
    ORDER BY c.Année, c.Trimestre, c.Mois
END
