require 'spec_helper'

describe "php::version" do
  let(:facts) { default_test_facts }
  let(:title) { "5.4.17" }

  it do
    should include_class("php")
    should include_class("boxen::config")
    should include_class("homebrew::config")
    should include_class("mysql::config")
  end

  context 'ensure => installed' do
    let(:params) do
      {
        :ensure  => "installed",
        :version => "5.4.17"
      }
    end

    it do
      should contain_exec("php-install-5.4.17").with({
        :command     => "/test/boxen/phpenv/bin/phpenv install 5.4.17",
        :provider    => "shell",
        :timeout     => "0",
        :creates     => "/test/boxen/phpenv/versions/5.4.17",
        :user        => "testuser",
        :require     => "Class[Php]",
        :environment => [
          "CFLAGS=-I/opt/X11/include",
          "PHPENV_ROOT=/test/boxen/phpenv",
          "PHP_BUILD_CONFIGURE_OPTS=
        --sysconfdir=/test/boxen/config/php/5.4.17
        --with-config-file-path=/test/boxen/config/php/5.4.17
        --with-config-file-scan-dir=/test/boxen/config/php/5.4.17/conf.d"
        ]
      })

      [
        "/test/boxen/data/php/5.4.17",
        "/test/boxen/config/php/5.4.17"
      ].each do |dir|
        should contain_file(dir).with({
          :ensure => "directory",
          :before => "Exec[php-install-5.4.17]"
        })
      end

      [
        "/test/boxen/config/php/5.4.17/conf.d",
        "/test/boxen/config/php/5.4.17/pool.d"
      ].each do |dir|
        should contain_file(dir).with({
          :ensure  => "directory",
          :purge   => "true",
          :force   => "true",
          :source  => 'puppet:///modules/php/empty-conf-dir',
          :require => "File[/test/boxen/config/php/5.4.17]"
        })
      end

      should contain_file("/test/boxen/config/php/5.4.17/php.ini").with({
        :content => File.read("spec/fixtures/php.ini"),
        :require => "File[/test/boxen/config/php/5.4.17]"
      })

      [
        "/test/boxen/log/php/5.4.17.error.log",
        "/test/boxen/log/php/5.4.17.fpm.error.log"
      ].each do |f|
        should contain_file(f).with({
          :owner => "testuser",
          :mode  => "0644"
        })
      end

      should contain_file("/test/boxen/config/php/5.4.17/php-fpm.conf").with({
        :content => File.read("spec/fixtures/php-fpm.conf"),
        :require => "File[/test/boxen/config/php/5.4.17]",
        :notify  => "Php::Fpm::Service[5.4.17]"
      })

      should contain_file("/test/boxen/config/php/5.4.17/pool.d/5.4.17.conf").with({
        :content => File.read("spec/fixtures/php-fpm-pool.conf")
      })

      should contain_php__fpm__service("5.4.17").with({
        :ensure    => "running",
        :subscribe => "File[/test/boxen/config/php/5.4.17/pool.d/5.4.17.conf]"
      })
    end
  end

  context "ensure => absent" do
    let(:params) do
      {
        :ensure  => "absent",
        :version => "5.4.17"
      }
    end

    it do
      [
        "/test/boxen/phpenv/versions/5.4.17",
        "/test/boxen/config/php/5.4.17",
        "/test/boxen/data/php/5.4.17"
      ].each do |dir|
        should contain_file(dir).with({
          :ensure => "absent",
          :force  => "true",
          :notify => "Exec[phpenv-rehash]"
        })
      end

      should contain_php__fpm__service("5.4.17").with_ensure("absent")
    end
  end
end
