# Public: Installs composer globally
#
# Usage:
#
#   include php::composer
#
class php::composer {
  require php

  $version = "1.0.0-alpha10"

  exec { 'download-php-composer':
    command => "curl -sS https://getcomposer.org/installer | php -- --version=${version} --install-dir=${php::config::root}/bin --filename=composer",
    unless  => "[ -f ${php::config::root}/bin/composer ] && [ \"`${php::config::root}/bin/composer --version | grep -ci '${version}'`\" == \"1\" ]",
    cwd     => $php::config::root,
    require => Exec['phpenv-setup-root-repo']
  } ->

  file { "${php::config::root}/bin/composer":
    mode => '0755'
  }
}