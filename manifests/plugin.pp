# Public: Install an phpenv plugin
#
# Usage:
#
#   php::plugin { 'phpenv-plugin':
#     ensure => 'v1.2.0',
#     source => 'phpenv/phpenv-plugin'
#   }

define php::plugin($ensure, $source) {
  require php

  repository { "${php::phpenv_pluginsdir}/${name}":
    ensure => $ensure,
    force  => true,
    source => $source,
    user   => $php::user
  }
}
