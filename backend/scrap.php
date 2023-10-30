
<?php
    $homepage = '';
    if (IsSet($_POST["url"])){ 
        $homepage = file_get_contents($_POST["url"],true);             
    }
    print $homepage;
?>
