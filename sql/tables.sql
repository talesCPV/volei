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
	id int(11) NOT NULL,
    id_user int(11) DEFAULT 0,
    id_treino int(11) NOT NULL,
    nick varchar(15) NOT NULL,    
    mensalista BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_user) REFERENCES tb_usuario(id),
    FOREIGN KEY (id_treino) REFERENCES tb_treinos(id),
    PRIMARY KEY (id,id_treino)
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

 DROP TABLE tb_agenda;
CREATE TABLE tb_agenda (	
    id_treino int(11) NOT NULL,
    data datetime NOT NULL,
    obs varchar(255) DEFAULT NULL,
    FOREIGN KEY (id_treino) REFERENCES tb_treinos(id),
    PRIMARY KEY (id_treino, data)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_agd_confirma;
CREATE TABLE tb_agd_confirma (
	id_atleta int(11) NOT NULL,
    id_treino int(11) NOT NULL,
    data datetime NOT NULL,
    vou BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_atleta) REFERENCES tb_atleta(id),
    FOREIGN KEY (id_treino) REFERENCES tb_treinos(id),
    PRIMARY KEY (id_atleta,id_treino, data)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

 DROP TABLE tb_warning;
CREATE TABLE tb_warning (
	id int(11) NOT NULL,
	id_atleta int(11) NOT NULL,
    message varchar(255) NOT NULL,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    callback varchar(255) DEFAULT "", 
    view BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_atleta) REFERENCES tb_atleta(id),
    PRIMARY KEY (id,id_atleta)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- DROP TABLE tb_following;
CREATE TABLE tb_following (
	id_host int(11) NOT NULL,
    id_guest int(11) NOT NULL,
	FOREIGN KEY (id_host) REFERENCES tb_usuario(id),
	FOREIGN KEY (id_guest) REFERENCES tb_usuario(id),
    PRIMARY KEY (id_host,id_guest)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE tb_message_agd;
CREATE TABLE tb_message_agd (
	id int(11) NOT NULL,
	id_treino int(11) NOT NULL,
    data datetime NOT NULL,
    id_usuario int(11) NOT NULL,
    data_scrap TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    
    scrap varchar(600) DEFAULT NULL,
	FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id),	
    PRIMARY KEY (id,id_treino,data)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;