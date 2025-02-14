<?php
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

$GLOBALS['wgServer'] = bsAssembleURL(
	[ 'WIKI_PROTOCOL', 'https' ],
	[ 'WIKI_HOST', 'localhost' ],
	[ 'WIKI_PORT', '443' ]
);

$GLOBALS['wgSitename'] = getenv( 'WIKI_NAME' ) ?: 'BlueSpice';
$GLOBALS['wgScriptPath'] = "/w";

$GLOBALS['wgResourceBasePath'] = $GLOBALS['wgScriptPath'];
$GLOBALS['wgLogos'] = [
	'1x' => $GLOBALS['wgResourceBasePath'] . '/resources/assets/change-your-logo.svg',
	'icon' => $GLOBALS['wgResourceBasePath']. '/resources/assets/change-your-logo-icon.svg',
];
$GLOBALS['wgEmergencyContact'] = getenv( 'WIKI_EMERGENCYCONTACT' ) ?: '';
$GLOBALS['wgPasswordSender'] = getenv( 'WIKI_PASSWORDSENDER' ) ?: '';
$GLOBALS['wgDBtype'] = getenv( 'DB_TYPE' ) ?: 'mysql';
$GLOBALS['wgDBserver'] = getenv( 'DB_HOST' ) ?: "database";
$GLOBALS['wgDBname'] = getenv( 'DB_NAME' ) ?: 'bluespice';
$GLOBALS['wgDBuser'] = getenv( 'DB_USER' ) ?: 'bluespice';
$GLOBALS['wgDBpassword'] = getenv( 'DB_PASS' );
$GLOBALS['wgDBprefix'] = getenv( 'DB_PREFIX' ) ?: '';
$GLOBALS['wgDBTableOptions'] = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
$cacheHost = getenv( 'CACHE_HOST' ) ?: 'cache';
$cachePort = getenv( 'CACHE_PORT' ) ?: '11211';
$GLOBALS['wgMemCachedServers'] = [ "$cacheHost:$cachePort" ];
unset( $cacheHost );
unset( $cachePort );
$GLOBALS['wgMainCacheType'] = CACHE_MEMCACHED;
$GLOBALS['wgSessionCacheType'] = CACHE_MEMCACHED;
$GLOBALS['wgMessageCacheType'] = CACHE_ACCEL;
$GLOBALS['wgLocalisationCacheConf']['store'] = 'array';
$GLOBALS['wgLocalisationCacheConf']['storeDirectory'] = "/tmp/cache/l10n";
$GLOBALS['wgEnableUploads'] = true;
$GLOBALS['wgUploadPath'] = $GLOBALS['wgScriptPath'] . '/img_auth.php';
$GLOBALS['wgUseImageMagick'] = true;
$GLOBALS['wgImageMagickConvertCommand'] = "/usr/bin/convert";
$GLOBALS['wgLanguageCode'] = getenv( 'WIKI_LANG' ) ?: "en";
$GLOBALS['wgLocaltimezone'] = "UTC";
$GLOBALS['wgSecretKey'] = getenv( 'INTERNAL_WIKI_SECRETKEY' );
$GLOBALS['wgAuthenticationTokenVersion'] = "1";
$GLOBALS['wgUpgradeKey'] = getenv( 'INTERNAL_WIKI_UPGRADEKEY' );
$GLOBALS['wgRightsPage'] = "";
$GLOBALS['wgRightsUrl'] = "";
$GLOBALS['wgRightsText'] = "";
$GLOBALS['wgRightsIcon'] = "";
$GLOBALS['wgMetaNamespace'] = "Site";
$GLOBALS['wgPhpCli'] = '/bin/php';
$GLOBALS['wgSMTP'] = [
	'host' => getenv( 'SMTP_HOST' ),
	'IDHost' => getenv( 'SMTP_IDHOST' ),
	'port' => getenv( 'SMTP_PORT' ) ?: 25,
	'auth' => getenv( 'SMTP_USER' ) ? true : false,
	'username' => getenv( 'SMTP_USER' ),
	'password' => getenv( 'SMTP_PASS' ),
];
if ( getenv( 'AV_HOST' ) ) {
	$GLOBALS['wgAntivirusSetup'] = [
		'clamav' => [
			'command' => 'clamdscan --no-summary',
			'codemap' => [
				"0" => AV_NO_VIRUS,
				"1" => AV_VIRUS_FOUND,
				"52" => AV_SCAN_ABORTED,
				"*" => AV_SCAN_FAILED,
			],
			'messagepattern' => '/.*?:(.*)/sim',
		],
	];
	$GLOBALS['wgAntivirus'] = 'clamav';
	$GLOBALS['wgAntivirusRequired'] = true;
}

$GLOBALS['wgOAuth2PrivateKey'] = '/data/bluespice/oauth_private.key';
$GLOBALS['wgOAuth2PublicKey'] = '/data/bluespice/oauth_public.key';

if ( getenv( 'DEV_WIKI_DEBUG' ) ) {
	#$GLOBALS['wgDebugToolbar'] = true;
	$GLOBALS['wgShowExceptionDetails'] = true;
	$GLOBALS['wgDevelopmentWarnings'] = true;
	$GLOBALS['wgDebugDumpSql'] = true;
}

if ( getenv( 'DEV_WIKI_DEBUG_LOGCHANNELS' ) ) {
	$logChannels = explode( ',', getenv( 'DEV_WIKI_DEBUG_LOGCHANNELS' ) );
	$logChannels = array_map( 'trim', $logChannels );
	foreach ( $logChannels as $channel ) {
		$GLOBALS['bsgDebugLogGroups'][$channel] = true;
	}
	unset( $logChannels );
}

// Taken from `extensions/BlueSpiceWikiFarm/src/Dispatcher.php`
// Not all of this may be required
$GLOBALS['wgUploadDirectory'] = "/data/bluespice/images";
$GLOBALS['wgReadOnlyFile'] = "{$GLOBALS['wgUploadDirectory']}/lock_yBgMBwiR";
$GLOBALS['wgFileCacheDirectory'] = "{$GLOBALS['wgUploadDirectory']}/cache";
$GLOBALS['wgDeletedDirectory'] = "{$GLOBALS['wgUploadDirectory']}/deleted";
$GLOBALS['wgCacheDirectory'] = "/data/bluespice/cache";

define( 'BSDATADIR', "/data/bluespice/extensions/BlueSpiceFoundation/data" ); //Present
define( 'BS_DATA_DIR', "{$GLOBALS['wgUploadDirectory']}/bluespice" ); //Future
define( 'BS_CACHE_DIR', "{$GLOBALS['wgFileCacheDirectory']}/bluespice" );
define( 'BS_DATA_PATH', "{$GLOBALS['wgUploadPath']}/bluespice" );

if ( getenv( 'EDITION' ) === 'farm' ) {
	$GLOBALS['wgWikiFarmConfig_instanceDirectory'] = '/data/bluespice/farm-instances/';
	$GLOBALS['wgWikiFarmConfig_archiveDirectory'] = '/data/bluespice/farm-archives/';
	$GLOBALS['wgWikiFarmConfig_dbAdminUser'] = getenv( 'DB_ROOT_USER' ) ?: 'root';
	$GLOBALS['wgWikiFarmConfig_dbAdminPassword'] = getenv( 'DB_ROOT_PASS' ) ?: $GLOBALS['wgDBpassword'];
	$GLOBALS['wgWikiFarmConfig_LocalSettingsAppendPath'] = "$IP/LocalSettings.BlueSpice.php";
	$GLOBALS['wgSharedDB'] = $GLOBALS['wgDBname'];
	$GLOBALS['wgSharedPrefix'] = $GLOBALS['wgDBprefix'];
	$GLOBALS['wgSharedTables'] = [ 'bs_translationtransfer_translations' ];
}

require_once '/data/bluespice/pre-init-settings.php';
if ( getenv( 'EDITION' ) === 'farm' ) {
	require_once "$IP/extensions/BlueSpiceWikiFarm/WikiFarm.setup.php";
}
else {
	require_once "$IP/LocalSettings.BlueSpice.php";
}

$GLOBALS['wgArticlePath'] = '/wiki/$1';
if ( getenv( 'EDITION' ) === 'farm' ) {
	if( FARMER_IS_ROOT_WIKI_CALL === false ) {
		$GLOBALS['wgArticlePath'] = '/' . FARMER_CALLED_INSTANCE . '/wiki/$1';
		$GLOBALS['wgWebDAVBaseUri'] = '/' . FARMER_CALLED_INSTANCE . '/webdav/';
		// We must store L10N cache file of ROOT_WIKI and INSTANCEs independently, as they have different extensions enabled,
		// which otherwise causes the cache to be invalidated all the time.
		$GLOBALS['wgLocalisationCacheConf']['storeDirectory'] = '/tmp/cache/l10n-instances';
	}
}

$GLOBALS['bsgESBackendHost'] = getenv( 'SEARCH_HOST' ) ?: 'search';
$GLOBALS['bsgESBackendPort'] = getenv( 'SEARCH_PORT' ) ?: '9200';
$GLOBALS['bsgESBackendTransport'] = getenv( 'SEARCH_PROTOCOL' ) ?: 'http';

$GLOBALS['wgPDFCreatorOpenHtml2PdfServiceUrl'] = bsAssembleURL(
	[ 'PDF_PROTOCOL', 'http' ],
	[ 'PDF_HOST', 'pdf' ],
	[ 'PDF_PORT', '8080' ]
);
$GLOBALS['wgPDFCreatorOpenHtml2PdfServiceUrl'] .= '/Html2PDF/v1';

$GLOBALS['wgPdfProcessor'] = '/usr/bin/gs';
$GLOBALS['wgPdfPostProcessor'] = $GLOBALS['wgImageMagickConvertCommand'];
$GLOBALS['wgPdfInfo'] = '/usr/bin/pdfinfo';
$GLOBALS['wgPdftoText'] = '/usr/bin/pdftotext';

if ( getenv( 'EDITION' ) !== 'free' ) {
	// FREE edition uses public diagrams.net service
	$GLOBALS['wgDrawioEditorBackendUrl'] = $GLOBALS['wgServer'] . '/_diagram/';
}

$GLOBALS['wgMathoidCli'] = [
	'/app/bin/mathoid-remote',
	bsAssembleURL(
		[ 'FORMULA_PROTOCOL', 'http' ],
		[ 'FORMULA_HOST', 'formula' ],
		[ 'FORMULA_PORT', '10044' ]
	),
];

$GLOBALS['wgSimpleSAMLphp_InstallDir'] = '/app/simplesamlphp';

require_once '/data/bluespice/post-init-settings.php';
