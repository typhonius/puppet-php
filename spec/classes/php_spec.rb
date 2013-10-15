require 'spec_helper'

describe "php" do
  let(:facts) { default_test_facts }
  let(:default_params) do
    {
      :phpenv_version => "v0.4.0",
      :phpenv_root    => "/test/boxen/phpenv",
      :user           => "boxenuser"
    }
  end

  let(:params) { default_params }

  it do
    should include_class("php::params")
    should include_class("autoconf")
    should include_class("libpng")
    should include_class("libtool")
    should include_class("openssl")
    should include_class("pcre")
    should include_class("pkgconfig")
    should include_class("boxen::config")
    should include_class("homebrew")

    should contain_file("/test/boxen/env.d/phpenv.sh").with_source("puppet:///modules/php/phpenv.sh")

    should contain_repository("/test/boxen/phpenv").with({
      :ensure => "v0.4.0",
      :source => "createdbypete/phpenv",
      :user   => "boxenuser"
    })

    should contain_file("/test/boxen/phpenv/plugins/php-build/share/php-build/default_configure_options").with({
      :content => File.read("spec/fixtures/default_configure_options"),
      :require => "Php::Plugin[php-build]"
    })

    [
      "/test/boxen/log/php",
      "/test/boxen/data/php",
      "/test/boxen/config/php",
      "/test/boxen/data/php/cache",
      "/test/boxen/data/php/cache/extensions",
    ].each do |dir|
      should contain_file(dir).with({
        :ensure  => "directory",
        :require => "Repository[/test/boxen/phpenv]"
      })
    end

    [
      "/test/boxen/phpenv/plugins",
      "/test/boxen/phpenv/phpenv.d",
      "/test/boxen/phpenv/phpenv.d/install",
      "/test/boxen/phpenv/shims",
      "/test/boxen/phpenv/versions",
    ].each do |dir|
      should contain_file(dir).with({
        :ensure  => "directory",
        :require => "Repository[/test/boxen/phpenv]"
      })
    end

    should contain_php__plugin("php-build").with({
      :ensure => "02e53a5484e2b84d1184dce40c9c05447ae0a934",
      :source => "CHH/php-build"
    })

    [
      "freetype",
      "jpeg",
      "gd",
      "libevent",
      "mcrypt",
      "homebrew/dupes/zlib"
    ].each do |pkg|
      should contain_package(pkg)
    end

    should contain_homebrew__tap("homebrew/dupes").with_before("Package[homebrew/dupes/zlib]")

    should contain_file("/Library/LaunchDaemons/dev.php-fpm.plist").with({
      :ensure  => "absent",
      :require => "Service[dev.php-fpm]"
    })

    should contain_service("dev.php-fpm").with_ensure("stopped")
  end
end
