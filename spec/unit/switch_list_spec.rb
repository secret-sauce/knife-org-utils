require File.expand_path('../../spec_helper', __FILE__)

describe KnifeOrgUtils::SwitchList do

  let ( :root ) do
    '/dot/chef'
  end

  let( :knife_rb ) do
    ::File.join( root, 'knife.rb' )
  end

  let ( :conf_dirs ) do
    %w(
      /dot/chef/server1/org1/
      /dot/chef/server1/org2/
      /dot/chef/server2/org1/
      /dot/chef/server2/org2/
      /dot/chef/server2/org3/
      /dot/chef/server3/org1/
    )
  end

  let( :knife_data ) do
    <<-TEXT.gsub /^\s+/, ''
      current_dir = File.dirname(__FILE__)
      log_level                :info
      log_location             STDOUT
      node_name                "username"
      client_key               "\#{current_dir}/username.pem"
      chef_server_url          "https://server2.com/organizations/org3"
      cache_type               'BasicFile'
      cache_options( :path => \"\#{ENV['HOME']}/.chef/checksums\" )
      cookbook_path            ["\#{current_dir}/../cookbooks"]'
    TEXT
  end

  before :each do
    @knife = KnifeOrgUtils::SwitchList.new
    allow( @knife ).to receive( :root ).and_return( root )
    allow( ::File ).to receive( :read ).with( knife_rb ).and_return( knife_data )
    allow( ::Dir ).to receive( :glob ).with( "#{root}/*/*/" ).and_return( conf_dirs )
  end

  it 'lists all configs' do
    expect( @knife.ui ).to receive( :msg ).with( '   server1/org1' )
    expect( @knife.ui ).to receive( :msg ).with( '   server1/org2' )
    expect( @knife.ui ).to receive( :msg ).with( '   server2/org1' )
    expect( @knife.ui ).to receive( :msg ).with( '   server2/org2' )
    expect( @knife.ui ).to receive( :msg ).with( "\xF0\x9F\x8D\xB4  server2/org3" )
    expect( @knife.ui ).to receive( :msg ).with( '   server3/org1' )
    @knife.run
  end

end
