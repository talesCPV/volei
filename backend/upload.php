<?php

  $out = 0;

  if (IsSet($_FILES["up_file"]) && IsSet($_POST["path"])){ 

    $filename = $_FILES["up_file"]["name"];
    if (IsSet($_POST["filename"])){

        $filename = $_POST["filename"] != "" ? $_POST["filename"] : $_FILES["up_file"]["name"];
    }

    $file = $_FILES["up_file"]["tmp_name"];
    $url = getcwd().$_POST["path"].$filename;
//  echo $url;
    if (file_exists($file)){
      if(move_uploaded_file($file, $url)){
        $out = 1;
      }
    }
  }

  print $out;

?>