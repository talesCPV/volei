<?php
/*
// banco D2S.com.br
    $usuario = 'd2soft98_smasherman';
    $senha= '#Lober377';
    $servidor = '50.116.87.200';
    $banco = 'd2soft98_backhand';
*/

// banco Backhand.com.br
$usuario = 'backha49_smasherman';
$senha= 'Tales@1977';
$servidor = '162.241.203.141';
$banco = 'backha49_volley';

    $conexao = new mysqli($servidor, $usuario, $senha, $banco);

    if (!$conexao){
        die ("Erro de conexão com localhost, o seguinte erro ocorreu -> ".mysql_error());
    }    

?>