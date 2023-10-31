 DROP VIEW vw_ranking;
 CREATE VIEW vw_ranking AS
	SELECT RNK.id_treino, ATL.id, ATL.nick, ROUND(AVG(RNK.saque),2) AS SAQUE_AVG, ROUND(AVG(RNK.passe),2) AS PASSE_AVG, ROUND(AVG(RNK.ataque),2) AS ATAQUE_AVG, ROUND(AVG(RNK.levanta),2) AS LEVANTA_AVG 
		FROM tb_ranking AS RNK
		INNER JOIN tb_atleta AS ATL
		ON RNK.id_avaliado = ATL.id
        AND RNK.id_treino = ATL.id_treino
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
	SELECT * FROM tb_agenda;        