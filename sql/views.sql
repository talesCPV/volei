-- DROP VIEW vw_ranking;
 CREATE VIEW vw_ranking AS
SELECT id_treino, id_avaliado,ROUND(AVG(saque),2) AS saque, ROUND(AVG(passe),2) AS passe, ROUND(AVG(ataque),2) AS ataque, ROUND(AVG(levanta),2) AS levanta 
FROM tb_ranking 
GROUP BY id_avaliado;

SELECT * FROM vw_ranking;