require 'spec_helper'

describe "php::fpm::5_3_21" do
  let(:facts) { default_test_facts }

  it do
    should contain_php__fpm("5.3.21")
  end
end
