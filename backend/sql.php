<?php

    $query_db = array(
        "0"  => 'CALL sp_login("x00","x01");',
        "1"  => 'CALL sp_setUser("x00","x01","x02","x03");',
        "2"  => 'CALL sp_setTreino("x00","x01","x02","x03","x04","x05","x06");',
        "3"  => 'SELECT * FROM vw_meus_treinos WHERE id_user=x00;', // DASHBOARD
        "4"  => 'CALL sp_delTreino("x00","x01");',
        "5"  => 'CALL sp_addAtleta("x00","x01","x02","x03","x04");',
        "6"  => 'CALL sp_vwTreinoAtl(x00,x01);', // Treino Atl
        "7"  => 'CALL sp_avalia("x00","x01",x02,"x03","x04","x05","x06","x07","x08");',
        "8"  => 'CALL sp_vwUsers(x00,"x01",0,10);',
        "9"  => 'CALL sp_linkAtl(x00,"x01",x02,x03);',
        "10" => 'CALL sp_delAtleta("x00",x01,x02);',
        "11" => 'SELECT * FROM vw_user_ranking WHERE id=x00;',
        "12" => 'CALL sp_setAgenda("x00",x01,"x02","x03");',
        "13" => 'SELECT * FROM vw_dashboard;',
        "14" => 'CALL sp_delAgenda("x00",x01,"x02");',
        "15" => 'CALL sp_vwConfirma_agd(x00,"x01");',
        "16" => 'CALL sp_setConfirma_agd("x00",x01,x02,"x03",x04);',
        "17" => 'SELECT * FROM tb_ranking WHERE id_treino=x00 AND id_avaliador=x01 AND  id_avaliado=x02;', 
        "18" => 'SELECT * FROM tb_warning WHERE id_atleta=x00 AND NOT view;', 
        "19" => 'CALL sp_markWarning("x00",x01);',
        "20" => 'CALL sp_follow("x00",x01);',
        "21" => 'SELECT * FROM vw_friends WHERE y00 = x00;',
        "22" => 'SELECT * FROM vw_perfil WHERE id_user=x00;',
    );

    $query_json = array(
        
        "1" => "CALL sp_AtvAtl(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "2" => "CALL sp_sets(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "3" => "CALL sp_gameTorn(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "4" => "CALL sp_addcourts_torn(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        "5" => "CALL sp_atvGuest(\"@OWNER\",@CLAUSE,'(@FIELDS)','(@VALUES)');",
        

    );


?>