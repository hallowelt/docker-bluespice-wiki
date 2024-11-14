<?php

$idpRemoteMetaData = require( __DIR__ . '/_bluespice-saml20-idp-remote-meta.php' );

$protocol = getenv('WIKI_PROTOCOL') ?? 'http';
$host = getenv('WIKI_HOST') ?? 'localhost';
$portSuffix = getenv('WIKI_PORT') ? ':' . getenv('WIKI_PORT') : '';
if ($protocol === 'http' && $portSuffix === ':80') {
	$portSuffix = '';
} elseif ($protocol === 'https' && $portSuffix === ':443') {
	$portSuffix = '';
}
$baseUrl = "$protocol://$host{$portSuffix}";

$config = [
	'admin' => [
		'core:AdminPassword',
	],
	'default-sp' => [
		'saml:SP',
		'entityID' => $baseUrl,
		'idp' => $idpRemoteMetaData['entityid'],
		'discoURL' => null,
		'privatekey' => '/data/simplesamlphp/certs/saml.pem',
		'certificate' => '/data/simplesamlphp/certs/saml.crt',
		'NameIDPolicy' => []
	]
];

unset( $idpRemoteMetaData );
unset($protocol);
unset($host);
unset($portSuffix);
unset($baseUrl);
