<?php

include (__DIR__ . '/config.php.dist');

$protocol = getenv('WIKI_PROTOCOL') ?? 'http';
$host = getenv('WIKI_HOST') ?? 'localhost';
$portSuffix = getenv('WIKI_PORT') ? ':' . getenv('WIKI_PORT') : '';
if ($protocol === 'http' && $portSuffix === ':80') {
	$portSuffix = '';
} elseif ($protocol === 'https' && $portSuffix === ':443') {
	$portSuffix = '';
}
$baseUrl = "$protocol://$host{$portSuffix}";

// TODO calculate from environment variable
$loglevel = SimpleSAML\Logger::WARNING;

$customConfig = [
	'baseurlpath' => "$baseUrl/_sp",
	'application' => [
		'baseURL' => $baseUrl
	],
	'module.enable' => [
		'exampleauth' => false,
		'core' => true,
		'admin' => true,
		'saml' => true
	],

	'auth.adminpassword' => getenv('INTERNAL_SIMPLESAMLPHP_ADMIN_PASS'),
	'admin.protectindexpage' => true,
	'admin.protectmetadata' => false,
	'admin.checkforupdates' => false,
	'session.cookie.secure' => true,
	'enable.http_post' => true,
	'secretsalt' => getenv('INTERNAL_SIMPLESAMLPHP_SECRET_SALT'),

	'logging.handler' => 'errorlog', //  write to stdout
	'logging.level' => $loglevel,
	'debug' => array(
		'saml' => false,
		'backtraces' => false,
		'validatexml' => false,
	),

	'cachedir' => '/data/simplesamlphp/cache/',
	'loggingdir' => '/data/simplesamlphp/logs/',
	'datadir' => '/data/simplesamlphp/data/',

	'showerrors' => false,
	'errorreporting' => true,

	'technicalcontact_name' => getenv('WIKI_NAME') ?? 'BlueSpice',
	'technicalcontact_email' => getenv('WIKI_EMERGENCYCONTACT') ?? '',
	'mail.transport.method' => 'smtp',
	'mail.transport.options' => [
		'host' => getenv( 'SMTP_HOST' ),
		'port' => getenv( 'SMTP_PORT' ) ?? 25,
		'username' => getenv( 'SMTP_USER' ),
		'password' => getenv( 'SMTP_PASS' ),
		'security' => 'tls'
	],
	'sendmail_from' => getenv('WIKI_EMERGENCYCONTACT') ?? '',

	'store.type' => 'sql',
	'store.sql.dsn' => 'mysql:dbname=' . (getenv('DB_NAME') ?? 'database') . ';host=' . getenv('DB_HOST'),
	'store.sql.username' => getenv('DB_USER'),
	'store.sql.password' => getenv('DB_PASS'),
	'store.sql.prefix' => 'SimpleSAMLphp_' . (getenv('DB_PREFIX') ?? ''),
];

$config = $customConfig + $config;

unset($customConfig);
unset($protocol);
unset($host);
unset($portSuffix);
unset($baseUrl);
