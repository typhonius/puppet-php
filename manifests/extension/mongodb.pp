# Installs the mongodb extension for a specific version of php.
#
# Usage:
#
#     php::extension::mongodb { 'mongodb for 5.4.10':
#       php     => '5.4.10',
#       version => '1.4.5'
#     }
#
define php::extension::mongodb(
  $php,
  $version = '1.1.8'
) {
  require php::config
  require openssl

  # Require php version eg. php::5_4_10
  # This will compile, install and set up config dirs if not present
  php_require($php)

  $extension    = 'mongodb'
  $package_name = "mongodb-${version}"
  $url          = "https://pecl.php.net/get/mongodb-${version}.tgz"

  # Final module install path
  $module_path  = "${php::config::root}/versions/${php}/modules/${extension}.so"

  # Additional options
  $configure_params = "--with-openssl-dir=${boxen::config::homebrewdir}/opt/openssl"

  php_extension { $name:
    extension        => $extension,
    version          => $version,
    package_name     => $package_name,
    package_url      => $url,
    homebrew_path    => $boxen::config::homebrewdir,
    phpenv_root      => $php::config::root,
    php_version      => $php,
    cache_dir        => $php::config::extensioncachedir,
    configure_params => $configure_params,
  }

  # Add config file once extension is installed
  file { "${php::config::configdir}/${php}/conf.d/${extension}.ini":
    content => template('php/extensions/generic.ini.erb'),
    require => Php_extension[$name],
  }

}
