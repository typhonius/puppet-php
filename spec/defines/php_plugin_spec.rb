require 'spec_helper'

describe "php::plugin" do
  let(:facts) { default_test_facts }
  let(:title) { 'my-php-plugin' }
  let(:params) do
    {
      :ensure => "master",
      :source => "boxen/my-php-plugin"
    }
  end

  it do
    should include_class("php")

    should contain_repository('/test/boxen/phpenv/plugins/my-php-plugin').with({
      :ensure  => "master",
      :force   => "true",
      :source  => "boxen/my-php-plugin",
      :user    => "testuser"
    })
  end
end
