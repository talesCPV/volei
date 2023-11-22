 SELECT * FROM vw_ranking;
 SELECT * FROM vw_user_ranking;
 SELECT * FROM vw_dashboard;
 SELECT * FROM vw_meus_treinos;
 SELECT * FROM vw_following;
 SELECT * FROM vw_friends;
 SELECT * FROM vw_perfil;
 SELECT * FROM vw_message_agd;
 SELECT * FROM vw_mail;
 SELECT * FROM vw_treinoAtl;
 
 
 DROP VIEW vw_ranking;
-- CREATE VIEW vw_ranking AS
	SELECT USR.id, USR.nick,
    (SELECT IFNULL(ROUND(AVG(saque),2),0)FROM tb_ranking WHERE id_avaliado=USR.id) AS SAQUE,
    (SELECT IFNULL(ROUND(AVG(passe),2),0)FROM tb_ranking WHERE id_avaliado=USR.id) AS PASSE,
    (SELECT IFNULL(ROUND(AVG(ataque),2),0)FROM tb_ranking WHERE id_avaliado=USR.id) AS ATAQUE,
    (SELECT IFNULL(ROUND(AVG(levanta),2),0)FROM tb_ranking WHERE id_avaliado=USR.id) AS LEVANTA
	FROM tb_usuario AS USR;
        
        
 DROP VIEW vw_user_ranking;
 CREATE VIEW vw_user_ranking AS
	SELECT  RNK.id, RNK.nick,RNK.SAQUE,RNK.PASSE,RNK.ATAQUE,RNK.LEVANTA,
    ROUND(((AVG(RNK.SAQUE) + AVG(RNK.PASSE) + AVG(RNK.ATAQUE) + AVG(RNK.LEVANTA))/4),2) AS NIVEL,
    (SELECT COUNT(*) FROM tb_warning WHERE id_atleta=RNK.id AND NOT view) AS WARNING,
	(SELECT COUNT(*) FROM tb_following WHERE id_host=RNK.id LIMIT 1) AS SEGUINDO,
    (SELECT COUNT(*) FROM tb_following WHERE id_guest=RNK.id LIMIT 1) AS SEGUIDO,
    (SELECT COUNT(*) FROM tb_atleta WHERE id_user=RNK.id LIMIT 1) AS TREINOS
		FROM vw_ranking AS RNK		
		GROUP BY RNK.id;        

        
        
        
 DROP VIEW vw_dashboard;
--  CREATE VIEW vw_dashboard AS
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
    SELECT ATL.id_user, ATL.nick,TRN.nome, AGD.data, AGD.obs, RNK.NIVEL, RNK.TREINOS, RNK.SEGUINDO, RNK.SEGUIDO,
    IF(AGD.data < CURDATE(), 1, 0) AS HAPPEND
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
    AND AGD.data BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE() + INTERVAL 30 DAY
    AND CFM.vou = 1;

    SELECT * FROM vw_perfil WHERE id_user=1;
    
 DROP VIEW vw_message_agd;
  CREATE VIEW vw_message_agd AS
		SELECT MSG.*,USR.nick 
		FROM tb_message_agd AS MSG
		INNER JOIN tb_usuario AS USR
		ON MSG.id_usuario = USR.id;
        
	SELECT * FROM vw_message_agd WHERE id_treino=12 AND data="2023-11-17 19:00:00";
        
 DROP VIEW vw_mail;
  CREATE VIEW vw_mail AS
		SELECT F_USR.nick AS fromName,T_USR.nick AS toName,MSG.* 
		FROM tb_mail AS MSG
		INNER JOIN tb_usuario AS F_USR
        INNER JOIN tb_usuario AS T_USR
		ON MSG.id_from = F_USR.id
        AND MSG.id_to = T_USR.id
        AND MSG.data >= CURDATE() - INTERVAL 30 DAY ORDER BY data DESC;
        
 DROP VIEW vw_treinoAtl;
  CREATE VIEW vw_treinoAtl AS        
	SELECT ATL.*, ROUND((saque+passe+ataque+levanta)/4,2) AS NIVEL
		FROM tb_atleta AS ATL
		INNER JOIN tb_treinos AS TRN
		ON ATL.id_treino = TRN.id
        AND ATL.id_user = 0		
	UNION
	SELECT ATL.id, ATL.id_user, ATL.id_treino, ATL.nick, ATL.mensalista, RNK.SAQUE AS saque, RNK.PASSE AS passe,
		RNK.ATAQUE AS ataque, RNK.LEVANTA AS levanta, ROUND((RNK.SAQUE+RNK.PASSE+RNK.ATAQUE+RNK.LEVANTA)/4,2) AS NIVEL
		FROM tb_atleta AS ATL
		INNER JOIN tb_treinos AS TRN
        INNER JOIN vw_ranking AS RNK
		ON ATL.id_treino = TRN.id
        AND RNK.id = ATL.id_user
        AND ATL.id_user != 0
		GROUP BY id_user, id_treino;
        