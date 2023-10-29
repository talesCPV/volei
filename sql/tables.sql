-- DROP TABLE tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) NOT NULL,
    hash varchar(77) NOT NULL,
    access int(11) DEFAULT 1,
    nick varchar(15) NOT NULL,
	UNIQUE KEY (hash),
	UNIQUE KEY (email),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_atleta;
CREATE TABLE tb_atleta (
	id int(11) NOT NULL AUTO_INCREMENT,
    id_user int(11) DEFAULT 0,
    id_treino int(11) NOT NULL,
    nick varchar(15) NOT NULL,    
    mensalista BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id),
    FOREIGN KEY (id_treino) REFERENCES tb_treinos(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_treinos;
CREATE TABLE tb_treinos (
	id int(11) NOT NULL AUTO_INCREMENT,	
    id_owner int(11) DEFAULT NULL,
    nome varchar(40) DEFAULT NULL,
    dia_sem varchar(30) DEFAULT "SEG,QUA,SEX",
    horario varchar(11) DEFAULT "20:00-22:00",
    local varchar(70) DEFAULT NULL,
    obs varchar(255) DEFAULT NULL,
    FOREIGN KEY (id_owner) REFERENCES tb_usuario(id),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

DROP TABLE tb_ranking;
CREATE TABLE tb_ranking (
    id_treino int(11) NOT NULL,
    id_avaliador int(11) NOT NULL,
    id_avaliado int(11) NOT NULL,
    saque double DEFAULT 1,
    passe double DEFAULT 1,
    ataque double DEFAULT 1,
    levanta double DEFAULT 1,
    FOREIGN KEY (id_treino) REFERENCES tb_treinos(id),
    FOREIGN KEY (id_avaliador) REFERENCES tb_atleta(id),
    FOREIGN KEY (id_avaliado) REFERENCES tb_atleta(id),
    PRIMARY KEY (id_treino,id_avaliador,id_avaliado)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;