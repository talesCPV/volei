<?php



    if (IsSet($_POST["cod"]) && IsSet($_POST["params"])){       

        $cod = $_POST["cod"];
        $params = json_decode($_POST["params"],true); 
        $rows = array();

        include "connect.php";        
        include "sql.php"; 

//echo $_POST["cod"];
        
        $query = $query_db[$cod];
        $i = 0;
        foreach($params as $key => $val ){
            $y = 'y'.str_pad(strval($i), 2, "0", STR_PAD_LEFT);
            $x = 'x'.str_pad(strval($i), 2, "0", STR_PAD_LEFT);
        
            $query = str_replace($y, $key,$query); // fields
            $query = str_replace($x, $val,$query); // values
            $i++;
        }

//   echo $query; 

            $result = mysqli_query($conexao, $query);
//  echo $result->affected_rows;         
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