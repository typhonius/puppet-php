require 'spec_helper'

describe "php::5_5" do
  let(:facts) { default_test_facts }

  it do
    should include_class("php")
    should include_class("php::5_5_4")

    should contain_file("/test/boxen/phpenv/versions/5.5").with({
      :ensure => "symlink",
      :force  => true,
      :target => "/test/boxen/phpenv/versions/5.5.4"
    })
  end
end
