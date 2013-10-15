require 'spec_helper'

describe "php::version" do
  let(:facts) { default_test_facts }
  let(:title) { "5.4.17" }

  it do
    should include_class("php")
    should include_class("mysql::config")
    should include_class("homebrew::config")
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
        :environment => ["CFLAGS=-I/opt/X11/include", "PHPENV_ROOT=/test/boxen/phpenv"]
      })

      should contain_file("/test/boxen/data/php/5.4.17").with_ensure("directory")
      should contain_file("/test/boxen/config/php/5.4.17").with_ensure("directory")
      should contain_file("/test/boxen/config/php/5.4.17/conf.d").with({
        :ensure  => "directory",
        :purge   => "true",
        :force   => "true",
        :require => "File[/test/boxen/config/php/5.4.17]"
      })

      should contain_file("/test/boxen/phpenv/versions/5.4.17/modules").with({
        :ensure  => "directory",
        :require => "Exec[php-install-5.4.17]"
      })

      should contain_file("/test/boxen/config/php/5.4.17/php.ini").with({
        :content => File.read("spec/fixtures/php.ini"),
        :require => "File[/test/boxen/config/php/5.4.17]"
      })

      should contain_file("/test/boxen/log/php/5.4.17.error.log").with({
        :owner => "testuser",
        :mode  => "0644"
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
          :force  => "true"
        })
      end
    end
  end
end
