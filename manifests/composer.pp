# Public: Installs composer globally
#
# Usage:
#
#   include php::composer
#
class php::composer inherits php {

  exec { 'download-php-composer':
    command => "curl -sS -o ${phpenv_root}/bin/composer http://getcomposer.org/download/1.0.0-alpha7/composer.phar",
    unless  => "[ -f ${phpenv_root}/bin/composer ] && [ \"`md5 -q ${phpenv_root}/bin/composer`\" = \"ef51599395560988ea3e16912bfd70f8\" ]",
    cwd     => $phpenv_root,
    require => Repository[$phpenv_root]
  } ->

  file { "${phpenv_root}/bin/composer":
    mode => '0755'
  }
}
