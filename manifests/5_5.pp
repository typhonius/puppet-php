# Installs php 5.5.4 and symlinks it as 5.5
#
# Usage:
#
#     include php::5_5
#
class php::5_5 inherits php {
  require php::5_5_4

  file { "${php::phpenv_root}/versions/5.5":
    ensure  => symlink,
    force   => true,
    target  => "${php::phpenv_root}/versions/5.5.4"
  }
}
