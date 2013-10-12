# Public: Installs composer globally
#
# Usage:
#
#   include php::composer
#
class php::composer {
  require php

  exec { 'download-php-composer':
    command => "curl -sS -o ${php::phpenv_root}/bin/composer https://getcomposer.org/composer.phar",
    creates => "${php::phpenv_root}/bin/composer",
    cwd     => $php::phpenv_root,
    require => Repository[$php::phpenv_root]
  } ->

  file { "${php::phpenv_root}/bin/composer":
    mode => '0755'
  }
}
