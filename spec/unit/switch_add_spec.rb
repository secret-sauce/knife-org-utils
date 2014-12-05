require File.expand_path( '../../spec_helper', __FILE__ )

describe KnifeOrgUtils::SwitchAdd do

  let :config_name do
    'HOST/ORG'
  end

  let :mock_dot_chef do
    '/path/to/chef/files'
  end

  let :mock_dest_path do
    ::File.join( mock_dot_chef, config_name )
  end

  let :mock_dot_chef_files do
    %w(
      /path/to/chef/files/knife.rb
      /path/to/chef/files/user.pem
      /path/to/chef/files/org-validator.pem
    )
  end

  let :knife_rb_data do
    {
      :chef_server_url => 'chef_server_url "http://HOST.NAME.TLD/organizations/ORG"',
      :node_name => 'node_name "user"',
      :validation_client_name => 'validation_client_name "org-validator"'
    }
  end

  let :knife_rb do
    knife_rb_data.values.join("\n")
  end

  let :knife_rb_http do
    data = knife_rb_data
    data[:chef_server_url] = 'chef_server_url "http://alton.brown/organizations/good_eats"'
    data.values.join("\n")
  end

  let :knife_rb_https do
    data = knife_rb_data
    data[:chef_server_url] = 'chef_server_url "https://giada.de.laurentiis/organizations/everyday_italian"'
    data.values.join("\n")
  end

  let :knife_rb_invalid do
    data = knife_rb_data
    data[:chef_server_url] = 'chef_sever_url "https://gordon.ramsay/organizations/hells_kitchen"'
    data.values.join("\n")
  end

  before :each do
    @knife = KnifeOrgUtils::SwitchAdd.new
    knife_rb_path = ::File.join(mock_dot_chef, '.chef/knife.rb')
    allow( ::File ).to receive( :read ).with( knife_rb_path ).and_return( knife_rb )
  end

  context 'if starter kit dir not provided' do
    it 'prints error, usage and exits' do
      expect( @knife.ui ).to receive( :fatal ).with( "You must specify the path to started kit CHEF-RERO-DIR." )
      expect( @knife ).to receive( :show_usage )
      expect{ @knife.run }.to raise_error( SystemExit )
    end
  end

  context 'if starter kit dir is provided' do
    before :each do
      @knife.name_args << mock_dot_chef
      expect( @knife ).to receive( :get_kit_files )
      expect( @knife ).to receive( :get_dest_path ).and_return( mock_dest_path )
    end

    context 'and branch does not exist' do
      it 'calls necessary methods' do
        expect( @knife ).to receive( :root ).and_return( mock_dot_chef )
        allow( ::File ).to receive( :directory? ).and_return( false )
        expect( ::FileUtils ).to receive( :mkpath ).once
        expect( @knife ).to receive( :copy_files ).once
        expect( @knife.ui ).to receive( :msg ).with( "Added #{config_name} to #{mock_dot_chef}.")
        @knife.run
      end
    end

    context 'and branch does exist' do
      it 'exists with proper message' do
        allow( ::File ).to receive( :directory? ).and_return( true )
        expect( @knife.ui ).to receive( :info ).with( "Configuration for #{mock_dest_path} already exists." )
        @knife.run
      end
    end
  end

  describe 'SwitchAdd.get_kit_files' do
    before :each do
      @knife.name_args << mock_dot_chef
    end

    context 'system exits if' do
      it 'not a directory' do
        allow( ::File ).to receive( :exists? ).and_return( false )
        expect( @knife.ui ).to receive( :fatal ).with( 'Valid starter kit is not found at /path/to/chef/files.' )
        expect{ @knife.get_kit_files }.to raise_error( SystemExit )
      end

      it 'not exists' do
        allow( ::File ).to receive( :directory? ).and_return( false )
        expect( @knife.ui ).to receive( :fatal ).with( 'Valid starter kit is not found at /path/to/chef/files.' )
        expect{ @knife.get_kit_files }.to raise_error( SystemExit )
      end
    end

    it 'returns file list' do
      allow( ::File ).to receive( :exists? ).and_return( true )
      allow( ::File ).to receive( :directory? ).and_return( true )
      expect( ::Dir ).to receive( :glob ).and_return( mock_dot_chef_files )
      expect( ::File ).to receive( :file? ).exactly( mock_dot_chef_files.length ).and_return( true )
      expect( @knife.get_kit_files ).to eq( mock_dot_chef_files )
    end

    describe 'SwitchAdd.copy_files' do
      it 'copies files into dot chef folder' do
        expect( @knife ).to receive( :root ).and_return( mock_dot_chef )
        expect( ::FileUtils ).to receive( :copy ).with( '/path/to/chef/files/org-validator.pem', '/path/to/chef/files/HOST/ORG/org-validator.pem' )
        expect( ::FileUtils ).to receive( :copy ).with( '/path/to/chef/files/knife.rb', '/path/to/chef/files/HOST/ORG/knife.rb' )
        expect( ::FileUtils ).to receive( :copy ).with( '/path/to/chef/files/user.pem', '/path/to/chef/files/HOST/user.pem' )
        @knife.copy_files( mock_dot_chef_files )
      end
    end
  end

  describe 'SwitchAdd.get_branch_name' do
    before :each do
      allow( @knife ).to receive( :kit_path ).and_return( mock_dot_chef )
    end

    context 'with valid knife.rb' do
      it 'returns host/org for http' do
        allow( ::File ).to receive( :read ).and_return( knife_rb_http )
        expect( @knife.get_config_name ).to eq( 'alton/good_eats' )
      end

      it 'reutrns host/org for https' do
        allow( ::File ).to receive( :read ).and_return( knife_rb_https )
        expect( @knife.get_config_name ).to eq( 'giada/everyday_italian' )
      end
    end

    context 'with invalid knife.rb' do
      it 'system exists' do
        allow( ::File ).to receive( :read ).and_return( knife_rb_invalid )
        expect( @knife.ui ).to receive( :fatal ).with( "Invalid knife.rb at /path/to/chef/files/knife.rb.")
        expect{ @knife.get_config_name }.to raise_error( SystemExit )
      end
    end
  end
end
