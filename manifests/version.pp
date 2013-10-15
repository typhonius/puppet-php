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
  include homebrew::config
  include mysql::config

  # Version must be supplied in Major.Minor.Patch format
  validate_re($version, '^5\.(3\.([^0-2]|[3-9]|[0-9]{2})|[4-5]\.\d+)$',
    'Please specify the Major.Minor.Patch version of PHP >=5.3.3')

  $dest = "${php::phpenv_root}/versions/${version}"

  # Log location
  $error_log = "${php::logdir}/${version}.error.log"

  # Data directory for this version
  $version_data_root = "${php::datadir}/${version}"

  # Config locations
  $version_config_root = "${php::configdir}/${version}"
  $php_ini             = "${version_config_root}/php.ini"
  $conf_d              = "${version_config_root}/conf.d"

  # Module location for PHP extensions
  $module_dir = "${dest}/modules"

  if $ensure == 'absent' {

    file {
      [
        $dest,
        $version_config_root,
        $version_data_root,
      ]:
      ensure => absent,
      force  => true,
      notify => Exec["phpenv-rehash-${version}"]
    }

    exec { "phpenv-rehash-${version}":
      command     => "${php::phpenv_root}/bin/phpenv rehash",
      require     => Class['php'],
      refreshonly => true
    }

  } else {

    $default_env = {
      'CFLAGS' => '-I/opt/X11/include',
      'PHPENV_ROOT' => $php::phpenv_root
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
    }

    file { $conf_d:
      ensure  => directory,
      purge   => true,
      force   => true,
      require => File[$version_config_root],
    }

    file { $module_dir:
      ensure  => directory,
      require => Exec["php-install-${version}"],
    }

    # Set up config file
    file { $php_ini:
      content => template('php/php.ini.erb'),
      require => File[$version_config_root]
    }

    # Log file
    file { $error_log:
      owner => $php::user,
      mode  => '0644',
    }
  }
}
