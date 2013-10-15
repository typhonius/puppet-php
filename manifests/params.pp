# Public: Configuration values for php
class php::params {
  case $::osfamily {
    'Darwin': {
      include boxen::config

      $phpenv_root = "${boxen::config::home}/phpenv"
      $logdir      = "${boxen::config::logdir}/php"
      $configdir   = "${boxen::config::configdir}/php"
      $datadir     = "${boxen::config::datadir}/php"
      $user        = $::boxen_user
    }

    default: {
      $rbenv_root = '/usr/local/share/phpenv'
      $logdir     = '/usr/local/share/php/log'
      $configdir  = '/usr/local/share/php/config'
      $datadir    = '/usr/local/share/php/data'
      $user       = 'root'
    }
  }

  $phpenv_version = 'v0.4.0'

  $phpenv_plugins = {
    'php-build' => {
      'ensure' => 'master',
      'source' => 'CHH/php-build'
    }
  }

  $phpenv_pluginsdir = "${root}/plugins"

  $cachedir          = "${datadir}/cache"
  $extensioncachedir = "${datadir}/cache/extensions"
}
