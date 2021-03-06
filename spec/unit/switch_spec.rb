require File.expand_path( '../../spec_helper', __FILE__ )

describe KnifeOrgUtils::Switch do

  let( :config ) do
    'server/org'
  end

  let( :root ) do
    '/dot/chef'
  end

  let( :knife_rb ) do
    [
      'current_dir = File.dirname(__FILE__)',
      'log_level                :info',
      'log_location             STDOUT',
      'node_name                "username"',
      'client_key               "#{current_dir}/username.pem"',
      'chef_server_url          "https://chef.server.com/organizations/org"',
      "cache_type               'BasicFile'",
      "cache_options( :path => \"\#{ENV['HOME']}/.chef/checksums\" )",
      'cookbook_path            ["#{current_dir}/../cookbooks"]'
    ]
  end

  let( :source_knife_rb ) do
    ::File.join( root, config, 'knife.rb' )
  end

  let( :dest_knife_rb ) do
    ::File.join( root, 'knife.rb' )
  end

  before :each do
    @knife = KnifeOrgUtils::Switch.new
    allow( @knife ).to receive( :root ).and_return( root )
  end

  context 'if branch not provided' do
    it 'prints usage' do
      expect( @knife.ui ).to receive( :fatal ).with( "You must specify an CONFIG name." )
      expect( @knife ).to receive( :show_usage )
      expect{ @knife.run }.to raise_error( SystemExit )
    end
  end

  context 'if config is provided' do
    before :each do
      @knife.name_args << config
    end

    it 'system exits if knife.rb is not found' do
      allow( ::File ).to receive( :exists? ).with( source_knife_rb ).and_return( false )
      expect( @knife.ui ).to receive( :fatal ).with( "#{source_knife_rb} not found for #{config} config." )
      expect( @knife ).to receive( :show_usage )
      expect{ @knife.run }.to raise_error( SystemExit )
    end

    context 'and source knife.rb is found' do
      before :each do
        @output = double('File')
        allow( ::File ).to receive( :exists? ).with( source_knife_rb ).and_return( true )
        allow( ::File ).to receive( :open ).with( dest_knife_rb, 'w' ).and_yield( @output )
        allow( ::File ).to receive( :foreach ).with( source_knife_rb )
          .and_yield( knife_rb[0] )
          .and_yield( knife_rb[1] )
          .and_yield( knife_rb[2] )
          .and_yield( knife_rb[3] )
          .and_yield( knife_rb[4] )
          .and_yield( knife_rb[5] )
          .and_yield( knife_rb[6] )
          .and_yield( knife_rb[7] )
          .and_yield( knife_rb[8] )
      end

      it 'writes new conf file' do
        expect( @output ).to receive( :write ).with( "# Generated by knife-org-utils for config server/org\n" ).ordered
        expect( @output ).to receive( :write ).with( "server_dir = '/dot/chef/server'\n" ).ordered
        expect( @output ).to receive( :write ).with( "org_dir = '/dot/chef/server/org'\n" ).ordered
        expect( @output ).to receive( :write ).with( "log_level :info\n" ).ordered
        expect( @output ).to receive( :write ).with( "log_location STDOUT\n" ).ordered
        expect( @output ).to receive( :write ).with( "node_name \"username\"\n" ).ordered
        expect( @output ).to receive( :write ).with( "client_key \"\#{server_dir}/username.pem\"\n" ).ordered
        expect( @output ).to receive( :write ).with( "chef_server_url \"https://chef.server.com/organizations/org\"\n" ).ordered
        expect( @knife.ui ).to receive( :msg ).with( "Switched to #{config} knife config.")
        @knife.run
      end
    end
  end

  context 'parse_config_name' do
    it 'parses server and org' do
      @knife.name_args << 'server_3/org_1'
      expect( @knife.server ).to eq( 'server_3' )
      expect( @knife.org ).to eq( 'org_1' )
      @knife.parse_config_name
    end

    it 'parses server and org with -\'s' do
      @knife.name_args << 'server-3/org-1'
      expect( @knife.server ).to eql( 'server-3')
      expect( @knife.org ).to eq( 'org-1' )
      @knife.parse_config_name
    end
  end
end
