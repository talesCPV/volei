<?php

    $query_db = array(
        "0"  => 'CALL sp_login("x00","x01");',
        "1"  => 'CALL sp_setUser("x00","x01","x02","x03");',
        "2"  => 'CALL sp_setTreino("x00","x01","x02","x03","x04","x05","x06");',
        "3"  => 'SELECT * FROM tb_treinos;', // DASHBOARD
        "4"  => 'CALL sp_delTreino("x00","x01");',
        "5"  => 'CALL sp_addAtleta("x00","x01","x02","x03","x04");',
        "6"  => 'CALL sp_vwTreinoAtl(x00,x01);', // Treino Atl
        "7"  => 'CALL sp_avalia("x00","x01",x02,"x03","x04","x05","x06","x07","x08");',
        "8"  => 'CALL sp_vwUsers(x00,"x01",0,10);',
        "9"  => 'CALL sp_linkAtl(x00,"x01",x02);',
        "10" => 'CALL sp_delAtleta("x00",x01);',

    );

    $query_json = array(
        
        "1" => "CALL sp_AtvAtl(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "2" => "CALL sp_sets(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "3" => "CALL sp_gameTorn(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "4" => "CALL sp_addcourts_torn(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "5" => "CALL sp_atvGuest(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        

    );


?>