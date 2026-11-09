<?php
// INTERNAL_ENABLE_FARM=true

$GLOBALS['wgWikiFarmConfig_instanceDirectory'] = '/data/bluespice/farm-instances/';
$GLOBALS['wgWikiFarmConfig_archiveDirectory'] = '/data/bluespice/farm-archives/';
$GLOBALS['wgWikiFarmConfig_dbAdminUser'] = trim( getenv( 'DB_ROOT_USER' ) ?: $GLOBALS['wgDBuser'] );
$GLOBALS['wgWikiFarmConfig_dbAdminPassword'] = trim( getenv( 'DB_ROOT_PASS' ) ?: $GLOBALS['wgDBpassword'] );
$GLOBALS['wgWikiFarmConfig_dbPrefix'] = trim( getenv( 'WIKI_FARM_DB_PREFIX' ) );
// Settings of the codebase are included by the Standard Bootstrapper of the container
$GLOBALS['wgWikiFarmConfig_LocalSettingsAppendPath'] = '/app/conf/StandardBootstrapper.php';
$GLOBALS['wgWikiFarmConfig_useSharedDB'] = getenv( 'WIKI_FARM_USE_SHARED_DB' ) ? true : false;
$GLOBALS['wgWikiFarmConfig_basePath'] = trim( getenv( 'WIKI_BASE_PATH' ) );
$GLOBALS['wgWikiFarmConfig_initialAdminUser'] = trim( getenv( 'WIKI_INITIAL_ADMIN_USER' ) ?: 'Admin' );
// Maximum number of instances, defined at build time of the image. Empty or `0` means unlimited
$instanceLimit = bsInfrastructureConfig( 'INTERNAL_FARM_INSTANCE_LIMIT' );
if ( ctype_digit( $instanceLimit ) && (int)$instanceLimit > 0 ) {
	$GLOBALS['wgWikiFarmConfig_instanceLimit'] = (int)$instanceLimit;
}
unset( $instanceLimit );
$GLOBALS['wgSharedDB'] = $GLOBALS['wgDBname'];
$GLOBALS['wgSharedPrefix'] = $GLOBALS['wgDBprefix'];
$GLOBALS['wgSharedTables'] = [ 'bs_translationtransfer_translations' ];

if ( $cacheUsed === 'redis' || $cacheUsed === 'valkey' ) {
	$GLOBALS['wgWikiFarmConfig_maintenanceScreenLoadCallback'] = static function () {
		// This is a duplicate from Farm.Base.post.php - added here specifically to configure PR queue
		// when showing "installation" maintenance screen
		$GLOBALS['mwsgProcessManagerQueueConfig']['farm-redis'] = [
			'class' => \BlueSpice\WikiFarm\ProcessQueue\FarmRedisProcessQueue::class,
			'args' => [ [
				'redisConfig' => [],
				'redisServer' => $GLOBALS['wgObjectCaches']['redis']['servers'][0],
				'isRoot' => FARMER_IS_ROOT_WIKI_CALL,
				'forInstance' => FARMER_CALLED_INSTANCE
			] ]
		];
		$GLOBALS['mwsgProcessManagerQueue'] = 'farm-redis';
	};
}
