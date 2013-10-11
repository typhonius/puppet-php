require 'spec_helper'

describe "php" do
  let(:facts) { default_test_facts }
  let(:default_params) do
    {
      :phpenv_version => "6499bb6c7b645af3f4e67f7e17708d5ee208453f",
      :phpenv_root    => "/test/boxen/phpenv",
      :user           => "boxenuser"
    }
  end

  let(:params) { default_params }

  it do
    should include_class("php::params")
    should include_class("boxen::config")

    should contain_file("/test/boxen/env.d/phpenv.sh").with_source("puppet:///modules/php/phpenv.sh")

    should contain_repository("/test/boxen/phpenv").with({
      :ensure => "6499bb6c7b645af3f4e67f7e17708d5ee208453f",
      :source => "phpenv/phpenv",
      :user   => "boxenuser"
    })

    should contain_repository("/test/boxen/phpenv/php-src").with({
      :source => "php/php-src",
      :user   => "boxenuser"
    })

    [
      "/test/boxen/log/php",
      "/test/boxen/data/php",
      "/test/boxen/data/php/cache",
      "/test/boxen/data/php/cache/extensions",
    ].each do |dir|
      should contain_file(dir).with({
        :ensure  => "directory",
        :require => "Repository[/test/boxen/phpenv]"
      })
    end

    should contain_file("/test/boxen/config/php").with({
      :ensure  => "directory",
      :recurse => "true",
      :purge   => "true",
      :force   => "true",
      :source  => "puppet:///modules/php/empty-conf-dir"
    })

    [
      "/test/boxen/phpenv/plugins",
      "/test/boxen/phpenv/phpenv.d",
      "/test/boxen/phpenv/phpenv.d/install",
      "/test/boxen/phpenv/shims",
      "/test/boxen/phpenv/versions",
      "/test/boxen/phpenv/libexec"
    ].each do |dir|
      should contain_file(dir).with({
        :ensure  => "directory",
        :require => "Repository[/test/boxen/phpenv]"
      })
    end

    should contain_file("/test/boxen/data/php/pear").with({
      :ensure  => "directory",
      :owner   => "boxenuser",
      :group   => "staff",
      :require => "File[/test/boxen/data/php]",
    })

    should contain_file("/Library/LaunchDaemons/dev.php-fpm.plist").with({
      :ensure  => "absent",
      :require => "Service[dev.php-fpm]"
    })

    should contain_service("dev.php-fpm").with_ensure("stopped")
  end
end
