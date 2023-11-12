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
            INSERT INTO tb_atleta (id,id_user,id_treino,nick,mensalista) VALUES (1,@id_owner,@id_treino,@nick,TRUE);
			INSERT INTO tb_ranking (id_treino,id_avaliador,id_avaliado) VALUES (@id_treino,@id_owner,@id_owner);
            SELECT @nick;
        END IF;

	END $$
DELIMITER ;

CALL sp_setTreino("DEFAULT","f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<","RACHA DE QUINTA","QUI","20:00-22:00","GREMIO","");

 DROP PROCEDURE sp_setAgenda;
DELIMITER $$
	CREATE PROCEDURE sp_setAgenda(
		IN Ihash varchar(77),
		IN Iid_treino int(11),
		IN Idata datetime,
		IN Iobs varchar(255)
    )
	BEGIN
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id=Iid_treino);        
		
        IF(@id_call = @id_owner) THEN
			
            SET @qtd = (SELECT COUNT(*) FROM tb_agenda);
        
			INSERT INTO tb_agenda (id_treino,data,obs) VALUES (Iid_treino,Idata,Iobs)
            ON DUPLICATE KEY UPDATE obs=Iobs;
            
            IF(@qtd < (SELECT COUNT(*) FROM tb_agenda))THEN
				BEGIN
					DECLARE done BOOLEAN DEFAULT FALSE;
					DECLARE _id BIGINT UNSIGNED;
					DECLARE cur CURSOR FOR SELECT id_user FROM tb_atleta WHERE id_treino=Iid_treino AND id_user!=0;
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;

					OPEN cur;

					insertLoop: LOOP
						FETCH cur INTO _id;
						IF done THEN
							LEAVE insertLoop;
						END IF;
                        
                        SELECT nome, local  INTO @nome, @local FROM tb_treinos WHERE id=Iid_treino LIMIT 1;
                        
/*                        SET @treino = (SELECT nome FROM tb_treinos WHERE id=Iid_treino LIMIT 1);*/
						SET @callback = CONCAT('{"origem":"agenda", "id_treino":',Iid_treino,', "nome":"', @nome,'","local":"',@local,'", "data":"',Idata,'", "obs":"',Iobs,'", "id_owner":',@id_owner,'}');
                        
						CALL sp_setWarning(_id,CONCAT("NOVO TREINO - ",@nome),@callback);
						END LOOP insertLoop;

					CLOSE cur;
				END;
                
            END IF;
            
			SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;            
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_setConfirma_agd;
DELIMITER $$
	CREATE PROCEDURE sp_setConfirma_agd(
		IN Ihash varchar(77),
        IN Iid_atleta int(11),
		IN Iid_treino int(11),
		IN Idata datetime,
        IN Ivou boolean
    )
	BEGIN
    
		SET @exist = (SELECT COUNT(*) FROM tb_agd_confirma WHERE id_atleta=Iid_atleta AND id_treino=Iid_treino AND data=Idata LIMIT 1);
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id=Iid_treino);
        SET @id_user = (SELECT id_user FROM tb_atleta WHERE id=Iid_atleta AND id_treino=Iid_treino);
		
        IF(@id_call = @id_owner OR @id_call = @id_user) THEN
			IF(@exist)THEN
				UPDATE tb_agd_confirma SET vou = Ivou WHERE id_atleta=Iid_atleta AND id_treino=Iid_treino AND data=Idata;
            ELSE
				INSERT INTO tb_agd_confirma (id_atleta,id_treino,data,vou) VALUES (Iid_atleta,Iid_treino,Idata,Ivou);
            END IF;
			SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;            
        END IF;
	END $$
DELIMITER ;

CALL sp_setConfirma_agd("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",2,7,"2023-11-04 10:00:00",0);

 DROP PROCEDURE sp_setMessage_agd;
DELIMITER $$
	CREATE PROCEDURE sp_setMessage_agd(    
		IN Ihash varchar(77),
        IN Iid int(11),
        IN Iid_treino int(11),
		IN Idata datetime,
		IN Iscrap varchar(600)
    )
	BEGIN
		SET @id_user = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);        		
        IF(Iid="") THEN
			SET Iid = (SELECT IFNULL(MAX(id),0)+1 FROM tb_message_agd WHERE id_treino=Iid_treino AND data=Idata);
		END IF;
                    
		INSERT INTO tb_message_agd (id,id_treino, data, id_usuario, scrap) VALUES (Iid,Iid_treino,Idata,@id_user,Iscrap)
        ON DUPLICATE KEY UPDATE scrap=Iscrap, data_scrap = CURRENT_TIMESTAMP;
        
        SELECT * FROM vw_message_agd WHERE id_treino=Iid_treino AND data=Idata;
        
	END $$
DELIMITER ;
CALL sp_setMessage_agd("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",,7,"2023-11-11 10:00:00","teste 123");

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
            INSERT INTO tb_ranking (id_treino, id_avaliador, id_avaliado) VALUES (Iid_treino,@id,@id);
            SELECT 1 AS OK;
            
		ELSE 
			SELECT 0 AS OK;
        END IF;

	END $$
DELIMITER ;

CALL sp_addAtleta("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<","11","0","PEDRO","1");


 DROP PROCEDURE sp_setWarning;
DELIMITER $$
	CREATE PROCEDURE sp_setWarning(		
		IN Iid_atleta int(11),
		IN IMessage varchar(255),
        IN Icallback varchar(255)
    )
	BEGIN    
		SET @new_id = (SELECT  IFNULL(MAX(id),0)+1 AS NEW_ID FROM tb_warning WHERE id_atleta = Iid_atleta);
		
		INSERT INTO tb_warning (id,id_atleta,message,callback) VALUES (@new_id,Iid_atleta,Imessage,Icallback);
		SELECT 1 AS OK;
        
	END $$
DELIMITER ;


 DROP PROCEDURE sp_markWarning;
DELIMITER $$
	CREATE PROCEDURE sp_markWarning(	
		IN Ihash varchar(77),
		IN Iid_warning int(11)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		
        IF( @id_call > 0)THEN
			UPDATE tb_warning SET view=1 WHERE id=Iid_warning AND id_atleta=@id_call ;
			SELECT 1 AS OK;
        ELSE
			SELECT 0 AS OK;
        END IF;        
	END $$
DELIMITER ;


/* FOLLOW */

-- DROP PROCEDURE sp_follow;
DELIMITER $$
	CREATE PROCEDURE sp_follow(
		IN Ihash varchar(77),
		IN Iid_guest int(11)
    )
	BEGIN	
		DECLARE Iid_host INT(11);
		SET Iid_host = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        
		IF ((SELECT COUNT(*) FROM tb_following WHERE id_host = Iid_host AND id_guest = Iid_guest)>0) THEN
		   DELETE FROM tb_following WHERE id_host = Iid_host AND id_guest = Iid_guest ;           
		ELSE
		   INSERT INTO tb_following (id_host,id_guest) VALUES (Iid_host,Iid_guest);
		END IF;    	
        SELECT COUNT(*) AS FOLLOW FROM tb_following WHERE id_guest = Iid_guest;

	END $$
DELIMITER ;

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
        
        IF(@id_avaliador = @id_owner OR @id_avaliador = @id_avaliador) THEN
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
        IN Iid_user int(11),
        IN Iid_treino int(11)
    )
	BEGIN
		    
        SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);        
        SET @has_atl = (SELECT COUNT(*) FROM tb_atleta WHERE id_treino = Iid_treino AND id_user=Iid_user); 
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id = Iid_treino);
        SET @nick = (SELECT nick FROM tb_usuario WHERE id = Iid_user);

        IF(@id_owner = @id_call AND @has_atl = 0) THEN
			UPDATE tb_atleta SET id_user=Iid_user, nick=@nick WHERE id=Iid_atleta AND id_treino=Iid_treino;
            SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;
        END IF;
        
	END $$
DELIMITER ;

CALL sp_linkAtl(2,"f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",2,7);

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
            DELETE FROM tb_agenda WHERE id_treino=Iid;
			DELETE FROM id_treino WHERE id_treino=Iid;
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
		IN Iid_atleta int(11),
        IN Iid_treino int(11)
    )
	BEGIN        
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        SET @id_user = (SELECT id_user FROM tb_atleta WHERE id=Iid_atleta AND id_treino=Iid_treino);
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id = Iid_treino);        
        
        IF(@id_call = @id_owner OR @id_call = @id_user) THEN
			DELETE FROM tb_ranking WHERE id_treino=Iid_treino AND (id_avaliado=Iid_atleta OR id_avaliador=@id_user);
			DELETE FROM tb_atleta WHERE id=Iid_atleta AND id_treino=Iid_treino;
            SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;
        END IF;

	END $$
DELIMITER ;

CALL sp_delAtleta("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",10);
CALL sp_delAtleta("p[#p[/p[#p[/?iMwF6bb1~M=i8(T#p?/[*wF6b1~M=i8(T#p?/[*wF6b1~M=i8(T#p?/[*wF6b1~M",3);


 DROP PROCEDURE sp_delAgenda;
DELIMITER $$
	CREATE PROCEDURE sp_delAgenda(		
        IN Ihash varchar(77),
        IN Iid_treino int(11),
		IN Idata datetime
    )
	BEGIN        
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        SET @id_owner = (SELECT id_owner FROM tb_treinos WHERE id = Iid_treino);        
        
        IF(@id_call = @id_owner) THEN
			DELETE FROM tb_agd_confirma WHERE id_treino=Iid_treino AND data=Idata;
			DELETE FROM tb_message_agd  WHERE id_treino=Iid_treino AND data=Idata;
			DELETE FROM tb_agenda       WHERE id_treino=Iid_treino AND data=Idata;
            SELECT 1 AS OK;
		ELSE 
			SELECT 0 AS OK;
        END IF;

	END $$
DELIMITER ;

 DROP PROCEDURE sp_delMessage_agd;
DELIMITER $$
	CREATE PROCEDURE sp_delMessage_agd(
        IN Ihash varchar(77),
        IN Iid int(11),
        IN Iid_treino int(11),
		IN Idata datetime
    )
	BEGIN        
		SET @id_call = (SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);     
        
        DELETE FROM tb_message_agd  WHERE id=Iid AND id_treino=Iid_treino AND data=Idata AND id_usuario = @id_call;        
		SELECT * FROM vw_message_agd WHERE id_treino=Iid_treino AND data=Idata;

	END $$
DELIMITER ;

	SELECT id FROM tb_usuario WHERE hash COLLATE utf8_general_ci = "f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<" COLLATE utf8_general_ci LIMIT 1;
	DELETE FROM tb_message_agd  WHERE id=10 AND id_treino=7 AND data="2023-11-11 10:00:00" AND id_usuario = 1;


CALL sp_delMessage_agd("f'lB9$rN`<'~l<$Z<9*~rBHT$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<-Z*xH9f6'T$rB3`0~N?l<",4,7,"2023-11-11 10:00:00");

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
		AVG_RNK.SAQUE_AVG,AVG_RNK.PASSE_AVG,AVG_RNK.ATAQUE_AVG,AVG_RNK.LEVANTA_AVG,
        ROUND(((AVG_RNK.SAQUE_AVG + AVG_RNK.PASSE_AVG + AVG_RNK.ATAQUE_AVG + AVG_RNK.LEVANTA_AVG)/4),2) AS NIVEL
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
		AVG_RNK.SAQUE_AVG,AVG_RNK.PASSE_AVG,AVG_RNK.ATAQUE_AVG,AVG_RNK.LEVANTA_AVG,
        ROUND(((AVG_RNK.SAQUE_AVG + AVG_RNK.PASSE_AVG + AVG_RNK.ATAQUE_AVG + AVG_RNK.LEVANTA_AVG)/4),2) AS NIVEL
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
    GROUP BY id_treino,id;
	END $$
DELIMITER ;

CALL sp_vwTreinoAtl(7,1);

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
			SELECT id,nick,email FROM tb_usuario WHERE nick COLLATE utf8_general_ci LIKE CONCAT('%',Inick COLLATE utf8_general_ci,'%')
            LIMIT Istart,IshowLimit;        
        ELSE 
			IF(Isel = 2) THEN
				SELECT id,nick,email FROM tb_usuario WHERE email COLLATE utf8_general_ci LIKE CONCAT('%',Inick COLLATE utf8_general_ci,'%')
				LIMIT Istart,IshowLimit;
			ELSE 
				SELECT id,nick,email FROM tb_usuario WHERE id = Inick;
			END IF;
		END IF;

	END $$
DELIMITER ;

CALL sp_vwUsersByName(2,'teste@',0,10);

-- DROP PROCEDURE sp_vwConfirma_agd;
DELIMITER $$
	CREATE PROCEDURE sp_vwConfirma_agd(		
		IN Iid_treino int(11),
		IN Idata datetime
    )
	BEGIN
    
		SELECT RNK.*, IFNULL((SELECT vou FROM tb_agd_confirma WHERE id_treino=RNK.id_treino AND id_atleta = RNK.id  AND data = Idata),2) AS GO
		FROM vw_ranking AS RNK
		WHERE id_treino = Iid_treino;

	END $$
DELIMITER ;

CALL sp_vwConfirma_agd(7,"2023-11-04 10:00:00");
SELECT vou FROM tb_agd_confirma WHERE id_treino=7 AND id_atleta =2  AND data = "2023-11-04 10:00:00";

CALL sp_vwConfirma_agd(9,"2023-11-11 10:00:00");

SELECT RNK.*, IFNULL((SELECT vou FROM tb_agd_confirma WHERE id_treino=RNK.id_treino AND id_atleta = RNK.id  AND data = "2023-11-09 20:00:00"),2) AS GO
		FROM vw_ranking AS RNK
		WHERE id_treino = 6;
