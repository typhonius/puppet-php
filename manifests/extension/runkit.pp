# Installs a php extension for a specific version of php.
#
# Usage:
#
#     php::extension::runkit { 'runkit for 5.4.10':
#       php     => '5.4.10',
#       version => '1.0.3'
#     }
#
define php::extension::runkit(
  $php,
  $version = '1.0.3'
) {
  include boxen::config

  require php::config

  # Get full patch version of PHP
  $patch_php_version = php_get_patch_version($php)

  # Require php version eg. php::5_4_10
  # This will compile, install and set up config dirs if not present
  php_require($patch_php_version)

  $extension = 'runkit'

  # Final module install path
  $module_path = "${php::config::root}/versions/${php}/modules/${extension}.so"

  # Clone the source respository
  # Use ensure_resource, because if you directly use the repository type, it
  # will result in duplicate resource errors when installing the extension in
  # two different PHP versions.
  ensure_resource(
    'repository',
    "${php::config::extensioncachedir}/runkit",
    {
      source => 'namesco/runkit'
    }
  )

  # Additional options
  $configure_params = ''

  php_extension { $name:
    provider         => 'git',

    extension        => $extension,
    version          => $version,

    homebrew_path    => $boxen::config::homebrewdir,
    phpenv_root      => $php::config::root,
    php_version      => $php,

    cache_dir        => $php::config::extensioncachedir,
    require          => Repository["${php::config::extensioncachedir}/runkit"],

    configure_params => $configure_params,
  }

  # Add config file once extension is installed

  file { "${php::config::configdir}/${php}/conf.d/${extension}.ini":
    content => template('php/extensions/runkit.ini.erb'),
    require => Php_extension[$name],
  }

}
