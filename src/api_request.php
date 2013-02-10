#!/usr/bin/php
<?php
/** 
 * Hiveminder php json encoder and api request handler
 *
 * PHP version 5
 *
 * @category Humor
 * @package  Hiveminder
 * @author   Maxwell Elliott <elliott.432@buckeyemail.osu.edu>
 * @license  MIT <http://opensource.org/licenses/MIT>
 * @link     http://www.reddit.com/user/I_AM_TEH_HIVEMIND/
 *
*/
$apiKey = $argv[3];
$apiSecret = $argv[4];
$message = array(
  'message' => array(
    'message' => $argv[2],
    'chatBotID' => (int)$argv[5],
    'timestamp' => time()
    ),
    'user' => array(
    'gender' => 'm',
    'externalID' => $argv[1]
    )
);
// construct the data
$host = "http://www.personalityforge.com/api/chat/";
$messageJSON = json_encode($message);
$hash = hash_hmac('sha256', $messageJSON, $apiSecret);

$url = $host."?apiKey=".$apiKey."&hash=".$hash."&message=".urlencode($messageJSON);

// Make the call using cURL
$ch = curl_init();

// set URL and other appropriate options
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

// make the call
$response = curl_exec($ch);
curl_close($ch);
echo $response
?>
