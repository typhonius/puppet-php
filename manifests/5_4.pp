# Installs php 5.4.17 and symlinks it as 5.4
#
# Usage:
#
#     include php::5_4
#
class php::5_4 {
  require php
  require php::5_4_20

  file { "${php::phpenv_root}/versions/5.4":
    ensure  => symlink,
    force   => true,
    target  => "${php::phpenv_root}/versions/5.4.20"
  }
}
