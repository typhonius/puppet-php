# Public: Installs composer globally
#
# Usage:
#
#   include php::composer
#
class php::composer {
  require php

  # Get composer config
  $test_params = $php::config::composer
  if is_hash($test_params) {
    if has_key($test_params, 'version') {
      $composer_version = $test_params['version']
      $composer_url = "https://getcomposer.org/download/${composer_version}/composer.phar"
    }
    if has_key($test_params, 'checksum') {
      $composer_checksum = $test_params['checksum']
    }
  }

  if empty($composer_version) {
    err('No Composer version has been specified. Cannot install Composer.')
  }
  if empty($composer_checksum) {
    err('No Composer checksum has been specified. Cannot install Composer.')
  }

  $composer_path = "${php::config::root}/bin/composer"

  exec { 'download-php-composer':
    command => "curl -sS -o ${composer_path} ${composer_url}",
    unless  => "[ -f ${composer_path} ] && [ \"`md5 -q ${composer_path}`\" = \"${composer_checksum}\" ]",
    cwd     => $php::config::root,
    loglevel => 'debug',
    require => Exec['phpenv-setup-root-repo']
  } ->

  file { $composer_path:
    mode => '0755'
  }

  # Add composer global bin to $PATH
  boxen::env_script { 'composer':
    source => 'puppet:///modules/php/composer_global_bin.sh',
    require => Exec['download-php-composer']
  }
}
