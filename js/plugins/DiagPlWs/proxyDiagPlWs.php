<?php

/****************************************************/
/************** Début configuration *****************/
/****************************************************/

// Url du Web Service
//
//$sUrlWs = "http://localhost:8080/prolexisws/ProLexisService";
//$sUrlWs = "http://mutualise2-ws.prolexis.com/prolexisws/ProLexisService";
$sUrlWs = "http://mutualise2-ws.prolexis.com/prolexisws/v3/ProLexisService";

/****************************************************/
/*************** Fin configuration ******************/
/****************************************************/


/**
 * Accède à une url avec données POST
 * et des header optionnels
 *
 * @param String $url Url cible
 * @param <type> $data Données POST
 * @param <type> $optional_headers Header de la requête
 * @return String Données récupérées
 */
function do_post_request($url, $data, $optional_headers = null)
{
    $params = array('http' => array(
        'method' => 'POST',
        'content' => $data
    ));
    if ($optional_headers !== null) {
        $params['http']['header'] = $optional_headers;
    }
    $ctx = stream_context_create($params);
    $fp = @fopen($url, 'rb', false, $ctx);
    if (!$fp) {
        throw new Exception("Problem with $url, $php_errormsg");
    }
    $response = @stream_get_contents($fp);
    if ($response === false) {
        throw new Exception("Problem reading data from $url, $php_errormsg");
    }
    return $response;
}


try {
    // Récupère les données POST de l'appel
    //
    $data = file_get_contents('php://input');

    // Header de la requête
    //
    $header = "Content-Type: text/xml;charset=UTF-8";

    // Transmission des données POST vers un autre url
    //
    $response = do_post_request($sUrlWs, $data, $header);

    // Contruction de la réponse
    //
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: text/xml;charset=UTF-8");
    header("Cache-Control: no-cache");
    header("Pragma: no-cache");
    header("Expires: Fri, 01 Jan 2010 05:00:00 GMT");

    echo($response);
}
catch(Exception $e){
    // Renvoit d'une erreur
    //
    header("HTTP/1.1 500 Internal Server Error");
}


?>
