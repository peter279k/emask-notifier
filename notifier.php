<?php

$composerLoadPath = __DIR__ . '/vendor/autoload.php';
$configPath = __DIR__ . '/config.php';

if (false === file_exists($composerLoadPath)) {
    echo 'Composer Autoload Path is not existed.' . PHP_EOL;
    exit(1);
}

if (false === file($configPath)) {
    echo 'Config path is not existed.' . PHP_EOL;
    exit(1);
}

require_once $composerLoadPath;
require_once $configPath;

use Carbon\Carbon;
use GuzzleHttp\Client;
use Vonage\SMS\Message\SMS;
use Vonage\Client as VonageClient;
use Vonage\Client\Credentials\Basic;
use Symfony\Component\DomCrawler\Crawler;

function sendSMS($notificationMessage): bool {
    $welcomeMessageFormat = "Hi %s,\n";
    $phoneFilePath = __DIR__ . '/phone.csv';

    if (false === file_exists($phoneFilePath)) {
        echo 'Cannot find phone.csv file!' . PHP_EOL;
        exit(1);
    }
    $handler = fopen($phoneFilePath, 'r');
    while (false === feof($handler)) {
        $str = (string)fgets($handler, 4096);
        if ('' === $str) {
            break;
        }
        $row = str_getcsv($str);
        $userName = $row[0];
        $userPhoneNumber = $row[1];
        $notificationMessage = sprintf($welcomeMessageFormat, $userName) . $notificationMessage;

        $basic  = new Basic(VONAGE_API_KEY, VONAGE_API_SECRET);
        $client = new VonageClient($basic);
        $response = $client->sms()->send(
            new SMS($userPhoneNumber, $userName, $notificationMessage)
        );
        $current = $response->current();

        echo sprintf('[%s] Message has been sent to %s. Message ID: %s', (string)Carbon::now(), $userName, $current->getMessageId()) . PHP_EOL;
    }

    fclose($handler);

    return true;
}

if ('10:00' !== Carbon::now()->format('H:i')) {
    echo 'Sorry! This worker only works at 10:00 every day' . PHP_EOL;
    exit(0);
}

$client = new Client();
$response = $client->request('GET', 'https://emask.taiwan.gov.tw/msk/index.jsp');
$body = (string)$response->getBody();

$crawler = new Crawler($body);
$notificationMsgLists = [];
$notificationElements = 'p[style="margin-top: 10px; margin-bottom: 10px; font-size: 14px; font-weight: 400;"]';
$crawler->filter($notificationElements)->reduce(function(Crawler $node, $index) use (&$notificationMsgLists) {
    $notificationMsgLists[$index] = $node->text();
});

if (5 !== count($notificationMsgLists)) {
    echo 'Notification Message fetching Error!' . PHP_EOL;
    exit(1);
}
array_pop($notificationMsgLists);

$notificationMessage = implode("\n", $notificationMsgLists);

$dateCount = preg_match_all('/(\d+\/\d+ \d+:\d+ - \d+\/\d+ \d+:\d+)/', $notificationMsgLists[2], $matched);
if (1 !== $dateCount) {
    echo 'Cannot filter date range!' . PHP_EOL;
    exit(1);
}

$now = Carbon::now();
$dateRange = explode(' - ', $matched[0][0]);
$startDate = $dateRange[0];
$endDate = $dateRange[1];

if (0 === $now->diff(Carbon::parse($startDate))->days) {
    echo 'Sending Message!' . PHP_EOL;
    $result = sendSMS($notificationMessage);

    if (false === $result) {
        echo sprintf('[%s]Sending Notification Message has been failed!', (string)$now) . PHP_EOL;
        exit(1);
    }

    echo sprintf('[%s]Sending Notification Message has been done!', (string)$now) . PHP_EOL;
    exit(0);
}

$now->addDay(-1);
if (0 === $now->diff(Carbon::parse($startDate))->days) {
    echo 'Sending Message!' . PHP_EOL;
    $result = sendSMS($notificationMessage);

    if (false === $result) {
        echo sprintf('[%s]Sending Notification Message has been failed!', (string)$now) . PHP_EOL;
        exit(1);
    }

    echo sprintf('[%s]Sending Notification Message has been done!', (string)$now) . PHP_EOL;
    exit(0);
}

echo sprintf('[%s] Do Nothing!', (string)$now) . PHP_EOL;
