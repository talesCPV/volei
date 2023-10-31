-- DROP PROCEDURE sp_login;
DELIMITER $$
	CREATE PROCEDURE sp_login(
		IN Iemail varchar(70),
		IN Ihash varchar(77)
    )
	BEGIN
		SELECT COUNT(*) AS login, IFNULL(nick,0) AS nick,  IFNULL(id,0) AS id, IFNULL(access,0) AS access FROM tb_usuario WHERE email COLLATE utf8_general_ci = Iemail COLLATE utf8_general_ci AND  hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1;
	END $$
DELIMITER ;

CALL sp_login("talescd@gmail.com","L,$@)6zDJh,T$^6rh)8Tz@B=`&j0t:~D+N5X?b(l2v<#F-P7ZAd*n4x>%H/R9¨­f,p6z@'J1T;^$h");

-- DROP PROCEDURE sp_setUser;
DELIMITER $$
	CREATE PROCEDURE sp_setUser(
		IN Iid int(11),
		IN Iemail varchar(70),
		IN Ihash varchar(77),
		IN Inick varchar(15)
    )
	BEGIN
    
		SET @edit = (SELECT COUNT(*) FROM tb_usuario WHERE id=Iid);
        
		IF(@edit) THEN
			UPDATE tb_usuario SET email=Iemail, nick=Inick, hash=Ihash WHERE id=Iid;
			SELECT 1 AS OK;
		ELSE
			SET @qtd_before = (SELECT COUNT(*) FROM tb_usuario);
			INSERT INTO tb_usuario (email,hash,nick) VALUES (Iemail,Ihash,Inick);
			IF((SELECT COUNT(*) FROM tb_usuario) > @qtd_before) THEN
				SELECT 1 AS OK;
			ELSE
				SELECT 0 AS OK;
			END IF;
        END IF;

	END $$
DELIMITER ;

CALL sp_newUser("DEFAULT","talescd@gmail.com","f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<");

 DROP PROCEDURE sp_setTreino;
DELIMITER $$
	CREATE PROCEDURE sp_setTreino(
		IN Iid int(11),
		IN Ihash varchar(77),
		IN Inome varchar(40),
		IN Idia_sem varchar(30),
		IN Ihorario varchar(11),
		IN Ilocal varchar(70),
		IN Iobs varchar(255)
    )
	BEGIN
        SET @id_owner = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @edit = (SELECT COUNT(*) FROM tb_treinos WHERE id=Iid);
	
        IF(@edit) THEN
			UPDATE tb_treinos SET nome=Inome, dia_sem=Idia_sem, horario=Ihorario,local=Ilocal,obs=Iobs WHERE id=Iid;
        ELSE
			INSERT INTO tb_treinos (id_owner,nome,dia_sem,horario,local,obs) VALUES (@id_owner,Inome,Idia_sem,Ihorario,Ilocal,Iobs);
            SET @id_treino = (SELECT MAX(id) FROM tb_treinos);
            SET @nick = (SELECT nick FROM tb_usuario WHERE id=@id_owner);            
            INSERT INTO tb_atleta (id_user,id_treino,nick,mensalista) VALUES (@id_owner,@id_treino,@nick,TRUE);
            SELECT @nick;
        END IF;

	END $$
DELIMITER ;

CALL sp_setTreino("DEFAULT","f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<","RACHA DE QUINTA","QUI","20:00-22:00","GREMIO","");

 DROP PROCEDURE sp_addAtleta;
DELIMITER $$
	CREATE PROCEDURE sp_addAtleta(		
        IN Ihash varchar(77),
		IN Iid_treino int(11),
		IN Iid_user int(11),
		IN Inick varchar(15),
        IN Imensalista BOOLEAN
    )
	BEGIN		
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id=Iid_treino);

        IF(@id_call = @id_owner) THEN
			SET @id = (SELECT (IFNULL(MAX(id),0)+1) AS id  FROM tb_atleta WHERE id_treino=Iid_treino);
			INSERT INTO tb_atleta (id,id_user,id_treino,nick,mensalista) VALUES (@id,Iid_user,Iid_treino,Inick,Imensalista);
            INSERT INTO tb_ranking (id_treino, id_avaliador, id_avaliado) VALUES (Iid_treino,@id_owner,(SELECT MAX(id) FROM tb_atleta));
            SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;
        END IF;

	END $$
DELIMITER ;

CALL sp_addAtleta("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<","6",0,TESTE,"0");

 DROP PROCEDURE sp_avalia;
DELIMITER $$
	CREATE PROCEDURE sp_avalia(
		IN Iid_treino int(11),
		IN Ihash varchar(77),
        IN Iid_avaliado int(11),
        IN Isaque double,
        IN Ipasse double,
        IN Iataque double,
        IN Ilevanta double,
        IN Inick varchar(77),
        IN Imensalista boolean
    )
	BEGIN
        SET @id_avaliador = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        SET @id_user = (SELECT id_user FROM tb_atleta WHERE id=Iid_avaliado AND id_treino=Iid_treino);
        SET @pode_avaliar = (SELECT COUNT(*) FROM tb_atleta WHERE id_treino=Iid_treino AND id_user=@id_avaliador AND @id_avaliador != @id_user);		
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id = Iid_treino);
        
        IF(@id_avaliador = @id_owner) THEN
			UPDATE tb_atleta SET nick=Inick, mensalista=Imensalista WHERE id_treino=Iid_treino AND id=Iid_avaliado;
        END IF;
        
        IF(@pode_avaliar) THEN
			INSERT INTO tb_ranking (id_treino,id_avaliador,id_avaliado,saque,passe,ataque,levanta)
            VALUES (Iid_treino,@id_avaliador,Iid_avaliado,Isaque,Ipasse,Iataque,Ilevanta)
            ON DUPLICATE KEY UPDATE
            saque=Isaque, passe=Ipasse, ataque=Iataque,levanta=Ilevanta;
			SELECT 1 AS OK;
        ELSE
			SELECT 0 AS OK;
        END IF;
	END $$
DELIMITER ;

CALL sp_avalia("6","f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",2,"3.41","1","1","1","RODRIGO","1");

 DROP PROCEDURE sp_linkAtl;
DELIMITER $$
	CREATE PROCEDURE sp_linkAtl(		
        IN Iid_atleta int(11),
		IN Ihash varchar(77),
        IN Iid_user int(11)
    )
	BEGIN
        SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        SET @id_treino = (SELECT id_treino FROM tb_atleta WHERE id = Iid_atleta); 
        SET @has_atl = (SELECT COUNT(*) FROM tb_atleta WHERE id_treino = @id_treino AND id_user=Iid_user); 
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id = @id_treino);

        IF(@id_owner = @id_call AND @has_atl = 0) THEN
			UPDATE tb_atleta SET id_user=Iid_user WHERE id=Iid_atleta;
            SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;
        END IF;
        
	END $$
DELIMITER ;


/* DELEÇÂO */

 DROP PROCEDURE sp_delTreino;
DELIMITER $$
	CREATE PROCEDURE sp_delTreino(
		IN Iid int(11),
		IN Ihash varchar(77)
    )
	BEGIN
        SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id=Iid);
    
        IF(@id_call = @id_owner) THEN
			DELETE FROM tb_ranking WHERE id_treino=Iid;
			DELETE FROM tb_atleta WHERE id_treino=Iid;
			DELETE FROM tb_treinos WHERE id=Iid;
			SELECT 1 AS OK;
        ELSE
			SELECT 0 AS OK;
        END IF;

	END $$
DELIMITER ;

 DROP PROCEDURE sp_delAtleta;
DELIMITER $$
	CREATE PROCEDURE sp_delAtleta(		
        IN Ihash varchar(77),
		IN Iid_atleta int(11)
    )
	BEGIN        
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        SELECT id_user,id_treino INTO @id_user,@id_treino FROM tb_atleta WHERE id=Iid_atleta;
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id = @id_treino);        
        
        IF(@id_call = @id_owner AND @id_user != @id_owner) THEN
			DELETE FROM tb_ranking WHERE id_treino=@id_treino AND (id_avaliado=Iid_atleta OR id_avaliador=@id_user);
			DELETE FROM tb_atleta WHERE id=Iid_atleta AND id_treino=@id_treino;
            SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;
        END IF;

	END $$
DELIMITER ;

CALL sp_delAtleta("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",10);

/* VIEWS */

 DROP PROCEDURE sp_vwTreinoAtl;
DELIMITER $$
	CREATE PROCEDURE sp_vwTreinoAtl(
		IN Iid_treino int(11),
		IN Iid_user int(11)
    )
	BEGIN
SELECT * FROM(    
	SELECT ATL.*, RNK.saque, RNK.passe, RNK.ataque, RNK.levanta, RNK.id_avaliador,
		AVG_RNK.SAQUE_AVG,AVG_RNK.PASSE_AVG,AVG_RNK.ATAQUE_AVG,AVG_RNK.LEVANTA_AVG
		FROM tb_atleta AS ATL
		INNER JOIN tb_ranking AS RNK
		INNER JOIN vw_ranking AS AVG_RNK
		ON ATL.id = RNK.id_avaliado
		AND AVG_RNK.id_treino = RNK.id_treino
		AND AVG_RNK.id = RNK.id_avaliado
		AND ATL.id_treino = Iid_treino
		AND RNK.id_avaliador = Iid_user
		AND RNK.id_treino = Iid_treino
		GROUP BY id
	UNION
	SELECT ATL.*, 1 AS saque, 1 AS passe, 1 AS ataque, 1 AS levanta, Iid_user AS id_avaliador,
		AVG_RNK.SAQUE_AVG,AVG_RNK.PASSE_AVG,AVG_RNK.ATAQUE_AVG,AVG_RNK.LEVANTA_AVG
		FROM tb_atleta AS ATL
		INNER JOIN tb_ranking AS RNK
		INNER JOIN vw_ranking AS AVG_RNK
		ON ATL.id = RNK.id_avaliado
		AND AVG_RNK.id_treino = RNK.id_treino
		AND AVG_RNK.id = RNK.id_avaliado
		AND ATL.id_treino = Iid_treino
		AND RNK.id_avaliador != Iid_user
		AND RNK.id_treino = Iid_treino
		GROUP BY id
	) AS tbl_Atl 
    GROUP BY id_treino,id_user;
	END $$
DELIMITER ;

CALL sp_vwTreinoAtl(6,2);

 DROP PROCEDURE sp_vwUsers;
DELIMITER $$
	CREATE PROCEDURE sp_vwUsers(
		IN Isel int(2),
		IN Inick varchar(15),
        IN Istart int(11),
        IN IshowLimit int(11)
    )
	BEGIN	         

		IF(Isel = 1) THEN
			SELECT id,email,nick FROM tb_usuario WHERE nick COLLATE utf8_general_ci LIKE CONCAT('%',Inick COLLATE utf8_general_ci,'%')
            LIMIT Istart,IshowLimit;        
        ELSE 
			IF(Isel = 2) THEN
				SELECT id,email,nick FROM tb_usuario WHERE email COLLATE utf8_general_ci LIKE CONCAT('%',Inick COLLATE utf8_general_ci,'%')
				LIMIT Istart,IshowLimit;
			ELSE 
				SELECT id,email,nick FROM tb_usuario WHERE id = Inick;
			END IF;
		END IF;

	END $$
DELIMITER ;

CALL sp_vwUsersByName(2,'teste@',0,10);