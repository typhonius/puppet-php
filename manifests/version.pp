# Installs a php version via phpenv.
# Takes ensure, env, and version params.
#
# Usage:
#
#     php::version { '5.3.20': }
#
# There are a number of predefined classes which can be used rather than
# using this class directly, which allows the class to be defined multiple
# times - eg. if you define it within multiple projects. For example:
#
#     include php::5_3_20
#
define php::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $name
) {
  require php
  include boxen::config
  include homebrew::config
  include mysql::config

  # Version must be supplied in Major.Minor.Patch format
  validate_re($version, '^5\.(3\.([^0-2]|[3-9]|[0-9]{2})|[4-5]\.\d+)$',
    'Please specify the Major.Minor.Patch version of PHP >=5.3.3')

  $dest = "${php::phpenv_root}/versions/${version}"

  # Log location
  $error_log     = "${php::logdir}/${version}.error.log"
  $fpm_error_log = "${php::logdir}/${version}.fpm.error.log"

  # Data directory for this version
  $version_data_root   = "${php::datadir}/${version}"
  $pid_file            = "${php::datadir}/${version}.pid"

  # Config locations
  $version_config_root = "${php::configdir}/${version}"
  $php_ini             = "${version_config_root}/php.ini"
  $conf_d              = "${version_config_root}/conf.d"
  $fpm_config          = "${version_config_root}/php-fpm.conf"
  $fpm_pool_config_dir = "${version_config_root}/pool.d"

  if $ensure == 'absent' {

    file {
      [
        $dest,
        $version_config_root,
        $version_data_root
      ]:
      ensure => absent,
      force  => true,
      notify => Exec['phpenv-rehash']
    }

    php::fpm::service{ $version:
      ensure => absent,
    }

  } else {

    $default_env = {
      'CFLAGS' => '-I/opt/X11/include',
      'PHPENV_ROOT' => $php::phpenv_root,
      'PHP_BUILD_CONFIGURE_OPTS' => "
        --sysconfdir=${version_config_root}
        --with-config-file-path=${version_config_root}
        --with-config-file-scan-dir=${conf_d}"
    }

    $final_env = merge($default_env, $env)

    exec { "php-install-${version}":
      command  => "${php::phpenv_root}/bin/phpenv install ${version}",
      provider => shell,
      timeout  => 0,
      creates  => $dest,
      user     => $php::user,
      require  => Class['php']
    }

    Exec["php-install-${version}"] {
      environment +> sort(join_keys_to_values($final_env, '='))
    }

    file {
      [
        $version_data_root,
        $version_config_root
      ]:
      ensure => directory,
      before => Exec["php-install-${version}"]
    }

    file {
      [
        $conf_d,
        $fpm_pool_config_dir
      ]:
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      source  => 'puppet:///modules/php/empty-conf-dir',
      require => File[$version_config_root],
    }

    # Set up config file
    file { $php_ini:
      content => template('php/php.ini.erb'),
      require => File[$version_config_root]
    }

    # Log file
    file {
      [
        $error_log,
        $fpm_error_log
      ]:
      owner => $php::user,
      mode  => '0644',
    }

    # Set up FPM config
    file { $fpm_config:
      content => template('php/php-fpm.conf.erb'),
      require => File[$version_config_root],
      notify  => Php::Fpm::Service[$version],
    }

    $pool_name         = $version
    $socket_path       = "${boxen::config::socketdir}/${version}"
    $pm                = 'static'
    $max_children      = 1

    # Additional non required options (as pm = static for this pool):
    $start_servers     = 1
    $min_spare_servers = 1
    $max_spare_servers = 1

    file { "${fpm_pool_config_dir}/${version}.conf":
      content => template('php/php-fpm-pool.conf.erb'),
    }

    # Launch our FPM Service

    php::fpm::service{ $version:
      ensure    => running,
      subscribe => File["${fpm_pool_config_dir}/${version}.conf"],
    }
  }
}
