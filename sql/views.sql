 DROP VIEW vw_ranking;
 CREATE VIEW vw_ranking AS
	SELECT RNK.id_treino, TRN.id_owner, ATL.id, ATL.id_user, ATL.nick, ROUND(AVG(RNK.saque),2) AS SAQUE_AVG, ROUND(AVG(RNK.passe),2) AS PASSE_AVG, ROUND(AVG(RNK.ataque),2) AS ATAQUE_AVG, ROUND(AVG(RNK.levanta),2) AS LEVANTA_AVG,
		ROUND(((AVG(RNK.saque) + AVG(RNK.passe) + AVG(RNK.ataque) + AVG(RNK.levanta))/4),2) AS NIVEL
		FROM tb_ranking AS RNK
		INNER JOIN tb_atleta AS ATL
        INNER JOIN tb_treinos AS TRN
		ON RNK.id_avaliado = ATL.id
        AND RNK.id_treino = ATL.id_treino
        AND TRN.id = RNK.id_treino
		GROUP BY RNK.id_avaliado, RNK.id_treino ;
        
SELECT * FROM vw_ranking;
SELECT * FROM tb_ranking;

 DROP VIEW vw_user_ranking;
 CREATE VIEW vw_user_ranking AS
	SELECT  USR.id, USR.nick, ROUND(AVG(RNK.saque),2) AS SAQUE, ROUND(AVG(RNK.passe),2) AS PASSE, ROUND(AVG(RNK.ataque),2) AS ATAQUE, ROUND(AVG(RNK.levanta),2) AS LEVANTA,
    ROUND(((AVG(RNK.saque) + AVG(RNK.passe) + AVG(RNK.ataque) + AVG(RNK.levanta))/4),2) AS NIVEL
		FROM tb_ranking AS RNK
		INNER JOIN tb_usuario AS USR
		ON RNK.id_avaliado = USR.id        
		GROUP BY USR.id;
        
 DROP VIEW vw_dashboard;
  CREATE VIEW vw_dashboard AS
	SELECT AGD.*, TRN.nome,
    TRN.local,  TRN.id_owner, GROUP_CONCAT(ATL.nick SEPARATOR ',') AS ATLETAS
    FROM tb_agenda AS AGD
    INNER JOIN tb_treinos AS TRN
    INNER JOIN tb_atleta AS ATL
    ON AGD.id_treino = TRN.id
    AND ATL.id_treino = TRN.id
    GROUP BY AGD.id_treino, AGD.data
    ORDER BY AGD.data DESC;
    

SELECT RNK.*, IFNULL((SELECT vou FROM tb_agd_confirma WHERE id_treino=RNK.id_treino AND id_atleta = RNK.id  AND data = ""),0) AS GO
FROM vw_ranking AS RNK;
