# Public: Install an phpenv plugin
#
# Usage:
#
#   php::plugin { 'phpenv-plugin':
#     ensure => 'v1.2.0',
#     source => 'phpenv/phpenv-plugin'
#   }

define php::plugin($ensure, $source) {
  include php

  repository { "${php::phpenv_root}/plugins/${name}":
    ensure => $ensure,
    force  => true,
    source => $source,
    user   => $php::user
  }
}
