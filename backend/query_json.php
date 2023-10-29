<?php

    if (IsSet($_POST["cod"]) && IsSet($_POST["json"]) && IsSet($_POST["clause"]) && IsSet($_POST["owner"])) {

        include "connect.php";        
        include "sql.php"; 

        $json = json_decode($_POST["json"],true);
        $query = $query_json[$_POST["cod"]];
        $clause = $_POST["clause"];
        $owner = $_POST["owner"];
        $rows = array();
        $fields = '';
        $values = '';

        if(is_array($json) ){
    
            for($i = 0; $i < count($json); $i++) {

                foreach($json[$i] as $key => $val ){
                    $i == 0 ? $fields = $fields . $key."," : 0;
                    $values = $values . '"'.$val.'",';
                }                
                $values = substr($values, 0,strlen($values)-1) ."),(";                        
              }

        }else{

            foreach($json as $key => $val ){
                $fields = $fields . $key.",";
                $values = $values . '"'.$val.'",';    
            }
        }

        $fields = substr($fields, 0,strlen($fields)-1) ."";
        $values = substr($values, 0,strlen($values)-(is_array($json)?3:1) ) ."";

        $query = str_replace("@OWNER" , $owner ,$query); // owner
        $query = str_replace("@CLAUSE", $clause,$query); // clauses
        $query = str_replace("@FIELDS", $fields,$query); // fields
        $query = str_replace("@VALUES", $values,$query); // values

//        echo $query;

        $result = mysqli_query($conexao, $query);
        if(is_object($result)){
            if($result->num_rows > 0){			
                while($r = mysqli_fetch_assoc($result)) {
                    $rows[] = $r;
                }
            }        
        }
        $conexao->close();        
        print json_encode($rows);

    }

?>