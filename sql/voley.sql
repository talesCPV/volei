use d2soft98_voley;

-- DROP TABLE tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) DEFAULT NULL,
    hash varchar(30) NOT NULL,
    class int(11) DEFAULT NULL,
    nome varchar(50) DEFAULT NULL,
    cel varchar(14) DEFAULT NULL,
	UNIQUE KEY (email),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- DROP TABLE tb_jogadores;
CREATE TABLE tb_jogadores (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(50) DEFAULT NULL,
    id_user int(11)  DEFAULT NULL,
    tipo varchar(10) DEFAULT "MENSALISTA",
    nivel int(11) DEFAULT 0,
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- DROP TABLE tb_grupos;
CREATE TABLE tb_grupos(
    grupo varchar(2) NOT NULL,
    id_jogador int(11) NOT NULL,
    FOREIGN KEY (id_jogador) REFERENCES tb_jogadores(id),
    PRIMARY KEY (grupo,id_jogador)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

-- DROP TABLE tb_jogos;
CREATE TABLE tb_jogos(
	id int(11) NOT NULL AUTO_INCREMENT,
    grupo varchar(2) NOT NULL,
    id_jogador_A int(11) NOT NULL,
    id_jogador_B int(11) NOT NULL,
    dia date DEFAULT 0,
    sets_1A int(11) DEFAULT 0,
    sets_1B int(11) DEFAULT 0,
    sets_2A int(11) DEFAULT 0,
    sets_2B int(11) DEFAULT 0,
    sets_3A int(11) DEFAULT 0,
    sets_3B int(11) DEFAULT 0,
    FOREIGN KEY (id_jogador_A) REFERENCES tb_jogadores(id),
    FOREIGN KEY (id_jogador_B) REFERENCES tb_jogadores(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 /************************************************************************/
 
select * from tb_jogadores;
select * from tb_grupos;
select * from tb_jogos where grupo = "C";
SELECT * FROM tb_jogadores WHERE id_user IS NULL ORDER BY nivel DESC;
select * from tb_usuario;

select MAX(id) AS new_id from tb_jogadores;

describe tb_jogos;
ALTER TABLE tb_jogos
ADD COLUMN hora datetime AFTER dia;

UPDATE tb_jogadores set id_user = NULL WHERE id=2;


INSERT INTO tb_jogos (grupo,id_jogador_A, id_jogador_B) VALUES ("C","3","4");

UPDATE tb_jogos SET id_jogador_A=2, id_jogador_B=16 WHERE id=44;

DELETE FROM tb_jogos WHERE id=44;

SELECT J.* , P1.nome AS jogador_A, P2.nome AS jogador_B
 FROM tb_jogos AS J
 INNER JOIN tb_jogadores AS P1
 INNER JOIN tb_jogadores AS P2
 ON  J.id_jogador_A = P1.id
 AND J.id_jogador_B = P2.id;
 
SELECT J.* , ((J.sets_1A > J.sets_1B)+(J.sets_2A>J.sets_2B)+(J.sets_3A>J.sets_3B)) AS PLACAR_A,((J.sets_1A < J.sets_1B)+(J.sets_2A<J.sets_2B)+(J.sets_3A<J.sets_3B)) AS PLACAR_B,   P1.nome AS jogador_A, P2.nome AS jogador_B
            FROM tb_jogos AS J
            INNER JOIN tb_jogadores AS P1
            INNER JOIN tb_jogadores AS P2
            ON  J.id_jogador_A = P1.id
            AND J.id_jogador_B = P2.id
            AND J.grupo = "A"
            ORDER BY J.dia DESC;
            
SELECT J.*, G.grupo,
	SUM((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B) > (JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)) AS VITORIA,  
	SUM((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B) < (JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)) AS DERROTA  
    FROM tb_jogadores AS J
	INNER JOIN tb_grupos AS G
	INNER JOIN tb_jogos AS JG
	ON J.id = G.id_jogador
	AND (J.id = JG.id_jogador_A OR J.id = JG.id_jogador_B)
	AND G.grupo = "A"      
	GROUP BY J.id
	ORDER BY J.nivel DESC;            
    
SELECT J.*, JG.grupo,
	SUM((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B) > (JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)) AS VITORIA,  
	SUM((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B) < (JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)) AS DERROTA  
    FROM tb_jogadores AS J	
	INNER JOIN tb_jogos AS JG
	ON (J.id = JG.id_jogador_A OR J.id = JG.id_jogador_B)
	AND JG.grupo = "C"      
	GROUP BY J.id
	ORDER BY J.nivel DESC;     
    
/* SELECIONAR JOGOS POR GRUPO COM RESULTADOS */    
SELECT J.* ,((J.sets_1A > J.sets_1B)+(J.sets_2A>J.sets_2B)+(J.sets_3A>J.sets_3B)) AS PLACAR_A,((J.sets_1A < J.sets_1B)+(J.sets_2A<J.sets_2B)+(J.sets_3A<J.sets_3B)) AS PLACAR_B,  P1.nome AS jogador_A, P2.nome AS jogador_B
            FROM tb_jogos AS J
            INNER JOIN tb_jogadores AS P1
            INNER JOIN tb_jogadores AS P2
            ON  J.id_jogador_A = P1.id
            AND J.id_jogador_B = P2.id
            AND J.grupo = "C"
            ORDER BY J.dia DESC;        
    
SELECT J.*, G.grupo,

        SUM(IF((JG.sets_1A > 0 OR JG.sets_1B > 0)AND(J.id = JG.id_jogador_A OR J.id = JG.id_jogador_B),1,0)) AS JOGOS,	
        SUM( IF ( 
                    (J.id = JG.id_jogador_A AND( (JG.sets_1A > JG.sets_1B)+(JG.sets_2A > JG.sets_2B)+(JG.sets_3A > JG.sets_3B) > 1)) OR
                    (J.id = JG.id_jogador_B AND( (JG.sets_1B > JG.sets_1A)+(JG.sets_2B > JG.sets_2A)+(JG.sets_3B > JG.sets_3A) > 1)) ,1,0)) AS VITORIA,		            
        SUM( IF ( 
                    (J.id = JG.id_jogador_A AND( (JG.sets_1A < JG.sets_1B)+(JG.sets_2A < JG.sets_2B)+(JG.sets_3A < JG.sets_3B) > 1)) OR
                    (J.id = JG.id_jogador_B AND( (JG.sets_1B < JG.sets_1A)+(JG.sets_2B < JG.sets_2A)+(JG.sets_3B < JG.sets_3A) > 1)) ,1,0)) AS DERROTA,
                    
		SUM( IF( 
					J.id = JG.id_jogador_A,(JG.sets_1A+JG.sets_2A),IF(
                    J.id = JG.id_jogador_B,(JG.sets_1B+JG.sets_2B),0))) AS G_PRO,
		SUM( IF( 
					J.id = JG.id_jogador_A,(JG.sets_1B+JG.sets_2B),IF(
                    J.id = JG.id_jogador_B,(JG.sets_1A+JG.sets_2A),0))) AS G_CONTRA,
		SUM( IF( 
					J.id = JG.id_jogador_A,((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B)),IF(
                    J.id = JG.id_jogador_B,((JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)),0))) AS S_PRO,
		SUM( IF( 
					J.id = JG.id_jogador_A,((JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)),IF(
                    J.id = JG.id_jogador_B,((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B)),0))) AS S_CONTRA
                    
        FROM tb_jogadores AS J
        INNER JOIN tb_grupos AS G
        INNER JOIN tb_jogos AS JG
        ON J.id = G.id_jogador
        AND (J.id = JG.id_jogador_A OR J.id = JG.id_jogador_B)
        AND G.grupo = "A"      
        GROUP BY J.id
        ORDER BY VITORIA DESC, JOGOS DESC;     
    
    
SELECT USR.*, ATL.id AS id_atleta, ATL.nome 
        FROM tb_usuario AS USR
        INNER JOIN tb_jogadores AS ATL
        ON USR.id = ATL.id_user
        AND USR.id=1;    
        
/* RANKING */

SELECT J.id, J.nome,

        SUM(IF((JG.sets_1A > 0 OR JG.sets_1B > 0)AND(J.id = JG.id_jogador_A OR J.id = JG.id_jogador_B),1,0)) AS JOGOS,	
        SUM( IF ( 
                    (J.id = JG.id_jogador_A AND( (JG.sets_1A > JG.sets_1B)+(JG.sets_2A > JG.sets_2B)+(JG.sets_3A > JG.sets_3B) > 1)) OR
                    (J.id = JG.id_jogador_B AND( (JG.sets_1B > JG.sets_1A)+(JG.sets_2B > JG.sets_2A)+(JG.sets_3B > JG.sets_3A) > 1)) ,1,0)) AS VITORIA,		            
        SUM( IF ( 
                    (J.id = JG.id_jogador_A AND( (JG.sets_1A < JG.sets_1B)+(JG.sets_2A < JG.sets_2B)+(JG.sets_3A < JG.sets_3B) > 1)) OR
                    (J.id = JG.id_jogador_B AND( (JG.sets_1B < JG.sets_1A)+(JG.sets_2B < JG.sets_2A)+(JG.sets_3B < JG.sets_3A) > 1)) ,1,0)) AS DERROTA,
                    
		SUM( IF( 
					J.id = JG.id_jogador_A,(JG.sets_1A+JG.sets_2A),IF(
                    J.id = JG.id_jogador_B,(JG.sets_1B+JG.sets_2B),0))) AS G_PRO,
		SUM( IF( 
					J.id = JG.id_jogador_A,(JG.sets_1B+JG.sets_2B),IF(
                    J.id = JG.id_jogador_B,(JG.sets_1A+JG.sets_2A),0))) AS G_CONTRA,
		SUM( IF( 
					J.id = JG.id_jogador_A,((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B)),IF(
                    J.id = JG.id_jogador_B,((JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)),0))) AS S_PRO,
		SUM( IF( 
					J.id = JG.id_jogador_A,((JG.sets_1A < JG.sets_1B)+(JG.sets_2A<JG.sets_2B)+(JG.sets_3A<JG.sets_3B)),IF(
                    J.id = JG.id_jogador_B,((JG.sets_1A > JG.sets_1B)+(JG.sets_2A>JG.sets_2B)+(JG.sets_3A>JG.sets_3B)),0))) AS S_CONTRA,
		
		SUM( JG.sets_1A+JG.sets_2A+JG.sets_1B+JG.sets_2B) AS GAMES,
        
        (
			SUM( IF( 
						J.id = JG.id_jogador_A,(JG.sets_1A+JG.sets_2A),IF(
						J.id = JG.id_jogador_B,(JG.sets_1B+JG.sets_2B),0)))
			/
            
            SUM( JG.sets_1A+JG.sets_2A+JG.sets_1B+JG.sets_2B)
		
		 ) * 100 AS PERC
                    
        FROM tb_jogadores AS J
        INNER JOIN tb_grupos AS G
        INNER JOIN tb_jogos AS JG
        ON J.id = G.id_jogador
        AND (J.id = JG.id_jogador_A OR J.id = JG.id_jogador_B)
        GROUP BY J.id
        ORDER BY PERC DESC;     
            
        