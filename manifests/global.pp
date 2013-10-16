# Public: specify the global php version for phpenv
#
# Usage:
#
#   class { 'php::global': version => '5.4.10' }
#
class php::global(
  $version = '5.4'
) inherits php {

  if $version != 'system' {
    require join(['php', join(split($version, '[.]'), '_')], '::')
  }

  file { "${php::phpenv_root}/version":
    ensure  => present,
    owner   => $php::user,
    mode    => '0644',
    content => "${version}\n",
  }
}
