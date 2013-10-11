# Class: php
#
# This module installs a full phpenv & php-build driven php stack
#
# Usage:
#
#     include php
#
class php(
  $phpenv_version    = $php::params::phpenv_version,
  $phpenv_root       = $php::params::phpenv_root,
  $user              = $php::params::user,
  $phpenv_pluginsdir = $php::params::phpenv_pluginsdir,
  $logdir            = $php::params::logdir,
  $configdir         = $php::params::configdir,
  $datadir           = $php::params::datadir,
  $cachedir          = $php::params::cachedir,
  $extensioncachedir = $php::params::extensioncachedir
) inherits php::params {

  if $::osfamily == 'Darwin' {
    include boxen::config

    file { "${boxen::config::envdir}/phpenv.sh":
      source => 'puppet:///modules/php/phpenv.sh' ;
    }
  }

  repository { $phpenv_root:
    ensure => $phpenv_version,
    source => 'phpenv/phpenv',
    user   => $user
  }

  # Cache the PHP src repository we'll need this for extensions
  # and at some point building versions #todo
  repository { "${phpenv_root}/php-src":
    source => 'php/php-src',
    user   => $user
  }

  file {
    [
      $logdir,
      $datadir,
      $cachedir,
      $extensioncachedir,
    ]:
    ensure  => directory,
    require => Repository[$phpenv_root]
  }

  # Ensure we only have config files managed by Boxen
  # to prevent any conflicts by shipping a (nearly) empty
  # dir, and recursively purging
  file { $configdir:
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/php/empty-conf-dir',
  }

  file {
    [
      "${phpenv_root}/plugins",
      "${phpenv_root}/phpenv.d",
      "${phpenv_root}/phpenv.d/install",
      "${phpenv_root}/shims",
      "${phpenv_root}/versions",
      "${phpenv_root}/libexec",
    ]:
      ensure  => directory,
      require => Repository[$phpenv_root]
  }

  # Shared PEAR data directory - used for downloads & cache
  file { "${datadir}/pear":
    ensure  => directory,
    owner   => $php::user,
    group   => 'staff',
    require => File[$datadir],
  }

  # Kill off the legacy PHP-FPM daemon as we're moving to per version instances
  file { '/Library/LaunchDaemons/dev.php-fpm.plist':
    ensure  => 'absent',
    require => Service['dev.php-fpm']
  }
  service { 'dev.php-fpm':
    ensure => stopped,
  }

  Repository[$phpenv_root] ->
    Repository["${phpenv_root}/php-src"] ->
    Php::Plugin <| |> ->
    Php::Version <| |>
}
