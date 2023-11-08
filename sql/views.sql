 SELECT * FROM vw_ranking;
 SELECT * FROM vw_user_ranking;
 SELECT * FROM vw_dashboard;
 SELECT * FROM vw_meus_treinos;
 SELECT * FROM vw_following;
 SELECT * FROM vw_friends;
 SELECT * FROM vw_perfil;
 
 
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
        
        
 DROP VIEW vw_user_ranking;
 CREATE VIEW vw_user_ranking AS
	SELECT  USR.id, USR.nick, ROUND(AVG(RNK.saque),2) AS SAQUE, ROUND(AVG(RNK.passe),2) AS PASSE, ROUND(AVG(RNK.ataque),2) AS ATAQUE, ROUND(AVG(RNK.levanta),2) AS LEVANTA,
    ROUND(((AVG(RNK.saque) + AVG(RNK.passe) + AVG(RNK.ataque) + AVG(RNK.levanta))/4),2) AS NIVEL,
    (SELECT COUNT(*) FROM tb_warning WHERE id_atleta=USR.id AND NOT view) AS WARNING,
	(SELECT COUNT(*) FROM tb_following WHERE id_host=USR.id LIMIT 1) AS SEGUINDO,
    (SELECT COUNT(*) FROM tb_following WHERE id_guest=USR.id LIMIT 1) AS SEGUIDO,
    (SELECT COUNT(*) FROM tb_atleta WHERE id_user=USR.id LIMIT 1) AS TREINOS
		FROM tb_ranking AS RNK
		INNER JOIN tb_usuario AS USR
        INNER JOIN tb_atleta AS ATL
		ON RNK.id_avaliado = ATL.id
        AND ATL.id_user = USR.id        
		GROUP BY USR.id
	UNION        
	SELECT  USR.id, USR.nick, 1.00 AS SAQUE, 1.00 AS PASSE, 1.00 AS ATAQUE, 1.00 AS LEVANTA, 1.00 AS NIVEL,
        (SELECT COUNT(*) FROM tb_warning WHERE id_atleta=USR.id AND NOT view) AS WARNING,
		(SELECT COUNT(*) FROM tb_following WHERE id_host=USR.id LIMIT 1) AS SEGUINDO,
        (SELECT COUNT(*) FROM tb_following WHERE id_guest=USR.id LIMIT 1) AS SEGUIDO,
		(SELECT COUNT(*) FROM tb_atleta WHERE id_user=USR.id LIMIT 1) AS TREINOS
		FROM tb_usuario AS USR        
		WHERE USR.id NOT IN(SELECT id_user FROM tb_atleta)
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
    

 DROP VIEW vw_meus_treinos;
  CREATE VIEW vw_meus_treinos AS
	SELECT TRN.*, ATL.id_user
    FROM tb_treinos AS TRN    
    INNER JOIN tb_atleta AS ATL
    ON ATL.id_treino = TRN.id
    ORDER BY id DESC
    LIMIT 50;


 DROP VIEW vw_warnings;
--  CREATE VIEW vw_warnings AS
	SELECT TRN.*, ATL.id_user
    FROM tb_treinos AS TRN    
    INNER JOIN tb_atleta AS ATL
    ON ATL.id_treino = TRN.id
    ORDER BY id DESC
    LIMIT 50;



 DROP VIEW vw_following;
  CREATE VIEW vw_following AS
	SELECT USR.id, USR.email, USR.nick, 
    (SELECT COUNT(*) FROM tb_following WHERE id_guest=USR.id) AS SEGUIDORES,
    (SELECT COUNT(*) FROM tb_following WHERE id_host=USR.id) AS SEGUINDO,
    GROUP_CONCAT((SELECT id_host FROM tb_following WHERE id_guest=USR.id) SEPARATOR ',') AS EU_SEGUIDORES,
	GROUP_CONCAT((SELECT id_guest FROM tb_following WHERE id_host=USR.id) SEPARATOR ',') AS EU_SEGUINDO
    FROM tb_usuario AS USR
    GROUP BY USR.id
    ORDER BY USR.id
    LIMIT 50;
    
    
-- DROP VIEW vw_friends;
 CREATE VIEW vw_friends AS
SELECT FW.id_host AS hostID,(SELECT nick FROM tb_usuario WHERE id=FW.id_host) AS hostname,US.id AS guestID, US.nick AS guestname,
	(SELECT COUNT(*) FROM tb_following WHERE id_host=FW.id_guest AND id_guest=FW.id_host) AS SEGUE_VOLTA
	FROM tb_following AS FW
	INNER JOIN tb_usuario AS US
	ON US.id = FW.id_guest;
    

 DROP VIEW vw_perfil;
  CREATE VIEW vw_perfil AS
    SELECT ATL.id AS id_user, ATL.nick,TRN.nome, AGD.data, AGD.obs, RNK.NIVEL, RNK.TREINOS, RNK.SEGUINDO, RNK.SEGUIDO
    FROM tb_agenda AS AGD
    INNER JOIN tb_atleta AS ATL
    INNER JOIN tb_treinos AS TRN
    INNER JOIN tb_agd_confirma AS CFM
    INNER JOIN vw_user_ranking AS RNK
    ON ATL.id_treino = AGD.id_treino
    AND TRN.id = ATL.id_treino
    AND CFM.id_treino = TRN.id
    AND CFM.id_atleta = ATL.id
    AND RNK.id = ATL.id_user
    AND CFM.data = AGD.data
    AND AGD.data BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE()
    AND CFM.vou = 1;