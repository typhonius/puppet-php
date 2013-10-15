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
  include autoconf
  include libpng
  include libtool
  include openssl
  include pcre
  include pkgconfig

  if $::osfamily == 'Darwin' {
    include boxen::config
    include homebrew

    file { "${boxen::config::envdir}/phpenv.sh":
      source  => 'puppet:///modules/php/phpenv.sh',
      require => Repository[$phpenv_root]
    }
  }

  repository { $phpenv_root:
    ensure => $phpenv_version,
    source => 'createdbypete/phpenv',
    user   => $user
  }

  file { "${phpenv_root}/plugins/php-build/share/php-build/default_configure_options":
    content => template('php/default_configure_options.erb'),
    require => Php::Plugin['php-build']
  }

  file {
    [
      $logdir,
      $datadir,
      $configdir,
      $cachedir,
      $extensioncachedir,
    ]:
    ensure  => directory,
    require => Repository[$phpenv_root]
  }

  file {
    [
      "${phpenv_root}/plugins",
      "${phpenv_root}/phpenv.d",
      "${phpenv_root}/phpenv.d/install",
      "${phpenv_root}/shims",
      "${phpenv_root}/versions",
    ]:
      ensure  => directory,
      require => Repository[$phpenv_root]
  }

  $_real_phpenv_plugins = merge($php::params::phpenv_plugins, $phpenv_plugins)
  create_resources('php::plugin', $_real_phpenv_plugins)

  package { [
      'freetype',
      'jpeg',
      'gd',
      'libevent',
      'mcrypt',
      'homebrew/dupes/zlib'
    ]:
  }

  homebrew::tap { 'homebrew/dupes':
    before => Package['homebrew/dupes/zlib']
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
    Php::Plugin <| |> ->
    Php::Version <| |>
}
