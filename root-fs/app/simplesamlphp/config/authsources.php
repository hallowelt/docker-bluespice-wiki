<?php

$idpRemoteMetaData = require( __DIR__ . '/_bluespice-saml20-idp-remote-meta.php' );

$config = [
	'admin' => [
		'core:AdminPassword',
	],
	'default-sp' => [
		'saml:SP',
		'entityID' => null,
		'idp' => $idpRemoteMetaData['entityid'],
		'discoURL' => null,
		'privatekey' => '/data/simplesamlphp/saml.pem',
		'certificate' => '/data/simplesamlphp/saml.crt',
		'NameIDPolicy' => false
	]
];

unset( $idpRemoteMetaData );
