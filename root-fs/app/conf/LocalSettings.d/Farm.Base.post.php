<?php
// INTERNAL_ENABLE_FARM=true

// Re-set this value for farm, as Dispatcher changed values
$GLOBALS['wgThumbnailScriptPath'] = $GLOBALS['wgScriptPath'] . '/thumb.php';

if( FARMER_IS_ROOT_WIKI_CALL === false ) {
	$GLOBALS['wgScriptPath'] =  trim( getenv( 'WIKI_BASE_PATH' ) ) . FARMER_CALLED_INSTANCE;
	$GLOBALS['wgArticlePath'] = trim( getenv( 'WIKI_BASE_PATH' ) ) . FARMER_CALLED_INSTANCE . '/' . trim( getenv( 'WIKI_ARTICLE_PATH' ) ?: 'wiki' ) . '/$1';
	$GLOBALS['wgWebDAVBaseUri'] = trim( getenv( 'WIKI_BASE_PATH' ) ) . FARMER_CALLED_INSTANCE . '/webdav/';
	// We must store L10N cache file of ROOT_WIKI and INSTANCEs independently, as they have different extensions enabled,
	// which otherwise causes the cache to be invalidated all the time.
	$GLOBALS['wgLocalisationCacheConf']['storeDirectory'] = '/tmp/cache/l10n-instances';

	// Setup file storage of uploadfiles _and_ farm instance vaults/archives to use S3, if configured
	if ( $s3Used ) {
		// Overwrite S3 bucket top subdirectory to use Sub-WikiID (see above)
		$GLOBALS['wgAWSBucketTopSubdirectory'] = $GLOBALS['wgScriptPath'];
	}

	// Setup process runner/wikicron to use Redis, if configured
	// Has to be done in post-init due to farm consts
	if ( $cacheUsed === 'redis' || $cacheUsed === 'valkey' ) {
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

		$GLOBALS['mwsgWikiCronStore'] = [
			'class' => \BlueSpice\WikiFarm\ProcessQueue\WikiCronRedisStore::class,
			'args' => [ [
				'redisConfig' => [],
				'redisServer' => $GLOBALS['wgObjectCaches']['redis']['servers'][0],
				'isRoot' => FARMER_IS_ROOT_WIKI_CALL,
				'forInstance' => FARMER_CALLED_INSTANCE
			] ]
		];
	}
}

// Setup file storage of uploadfiles _and_ farm instance vaults/archives to use S3, if configured
if ( $s3Used ) {
	// Original local FS backend configured in Extension:BlueSpiceWikiFarm is not used.
	unset( $GLOBALS['wgFileBackends']['_instances'] );
	$GLOBALS['wgWikiFarmConfig_instanceStorageBackend'] = $GLOBALS['mwsgFileStorageBackend'];
}
