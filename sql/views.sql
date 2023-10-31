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