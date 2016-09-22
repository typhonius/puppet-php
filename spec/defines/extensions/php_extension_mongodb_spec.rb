require 'spec_helper'

describe "php::extension::mongodb" do
  let(:facts) { default_test_facts }
  let(:title) { "mongodb for 5.6.26" }
  let(:params) do
    {
      :php     => "5.6.26",
      :version => "1.1.8"
    }
  end

  it do
    should contain_class("openssl")
    should contain_class("php::config")
    should contain_php__version("5.6.26")

    should contain_php_extension("mongodb for 5.6.26").with({
      :extension        => "mongodb",
      :version          => "1.1.8",
      :package_name     => "mongodb-1.1.8",
      :package_url      => "https://pecl.php.net/get/mongodb-1.1.8.tgz",
      :homebrew_path    => "/test/boxen/homebrew",
      :phpenv_root      => "/test/boxen/phpenv",
      :php_version      => "5.6.26",
      :cache_dir        => "/test/boxen/data/php/cache/extensions",
      :configure_params => "--with-openssl-dir=/test/boxen/homebrew/opt/openssl",
    })

    should contain_file("/test/boxen/config/php/5.6.26/conf.d/mongodb.ini").with({
      :content => File.read("spec/fixtures/mongodb.ini"),
      :require => "Php_extension[mongodb for 5.6.26]"
    })
  end
end
