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
$GLOBALS['wgSharedDB'] = $GLOBALS['wgDBname'];
$GLOBALS['wgSharedPrefix'] = $GLOBALS['wgDBprefix'];
$GLOBALS['wgSharedTables'] = [ 'bs_translationtransfer_translations' ];
