<?php

$config['db_host'] = getenv('DB_HOST');
$config['db_port'] = intval(getenv('DB_PORT') ?: 3306);
$config['db_user'] = getenv('DB_USER');
if (getenv('DB_PASS_FILE')) {
    $config['db_pass'] = trim(file_get_contents(getenv('DB_PASS_FILE')));
} else {
    $config['db_pass'] = getenv('DB_PASS');
}
$config['db_name'] = getenv('DB_NAME');
$config['db']['extension'] = 'mysqli';

$config['user'] = 'librenms';
$config['base_url'] = getenv('LIBRENMS_DOMAIN');
$config['snmp']['community'] = array("COMMUNITY_SNMP");
$config['auth_mechanism'] = "mysql";
$config['rrd_purge'] = 0;
$config['enable_billing'] = 1;
$config['show_services'] = 1;
$config['update'] = 0;

$config['nagios_plugins']   = "/usr/lib/nagios/plugins";

$config['rrdtool_version'] = '1.7.0';
$config['rrdcached'] = getenv('RRDCACHED_CONNECT') ?: "unix:/var/run/rrdcached/rrdcached.sock";

$config['memcached']['enable'] = filter_var(getenv('MEMCACHED_ENABLE'), FILTER_VALIDATE_BOOLEAN);
$config['memcached']['host'] = getenv('MEMCACHED_HOST');
$config['memcached']['port'] = intval(getenv('MEMCACHED_PORT') ?: 11211);
$config['memcached']['ttl'] = 240;


// include internal config

$configFiles = glob(__DIR__ . '/conf.internal.d/*.php');
natcasesort($configFiles);

foreach ($configFiles as $file) {
        include $file;
}

// include custom config

$configFiles = glob(__DIR__ . '/conf.d/*.php');
natcasesort($configFiles);

foreach ($configFiles as $file) {
        include $file;
}