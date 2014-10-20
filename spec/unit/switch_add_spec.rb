require File.expand_path( '../../spec_helper', __FILE__ )

describe KnifeOrgUtils::SwitchAdd do

  let :mock_dot_chef do
    '/path/to/chef/files'
  end

  let :mock_dot_chef_files do
    %w(
      /path/to/chef/files/knife.rb
      /path/to/chef/files/user.pem
      /path/to/chef/files/org-validator.pem
    )
  end

  before :each do
    @knife = KnifeOrgUtils::SwitchAdd.new
    @git = double( 'Git' )
    allow( ::Git ).to receive( :open ).and_return( @git )
  end

  context 'if starter kit dir not provided' do
    it 'prints error, usage and exits' do
      expect( @knife.ui ).to receive( :fatal ).with( "You must specify the path to started kit CHEF-RERO-DIR" )
      expect( @knife ).to receive( :show_usage )
      expect{ @knife.run }.to raise_error( SystemExit )
    end
  end

  context 'if starter kit dir is provided' do
    before :each do
      @knife.name_args << mock_dot_chef
      expect( @knife ).to receive( :get_kit_files )
      expect( @knife ).to receive( :get_branch_name ).and_return( 'HOST/ORG' )
    end

    context 'and branch does not exist' do
      it 'calls necessary methods' do
        allow( @knife ).to receive( :branch_exists? ).and_return( false )
        expect( @knife ).to receive( :checkout ).once
        expect( @knife ).to receive( :clean_files ).once
        expect( @knife ).to receive( :copy_files ).once
        expect( @knife ).to receive( :commit ).once
        @knife.run
      end
    end

    context 'and branch does exist' do
      it 'exists with proper message' do
        allow( @knife ).to receive( :branch_exists? ).and_return( true )
        expect( @knife.ui ).to receive( :info ).with( 'Branch for HOST/ORG already exists' )
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
        expect( @knife.ui ).to receive( :fatal ).with( 'Valid starter kit is not found at /path/to/chef/files' )
        expect{ @knife.get_kit_files }.to raise_error( SystemExit )
      end

      it 'not exists' do
        allow( ::File ).to receive( :directory? ).and_return( false )
        expect( @knife.ui ).to receive( :fatal ).with( 'Valid starter kit is not found at /path/to/chef/files' )
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
  end

  describe 'SwitchAdd.get_branch_name' do
    before :each do
      allow( @knife ).to receive( :kit_path ).and_return( mock_dot_chef )
    end

    context 'with valid knife.rb' do
      it 'returns host/org for http' do
        knife_rb = 'chef_server_url "http://alton.brown/organizations/good_eats"'
        allow( ::File ).to receive( :read ).and_return( knife_rb )
        expect( @knife.get_branch_name ).to eq( 'alton/good_eats' )
      end

      it 'reutrns host/org for https' do
        knife_rb = 'chef_server_url "https://giada.de.laurentiis/organizations/everyday_italian"'
        allow( ::File ).to receive( :read ).and_return( knife_rb )
        expect( @knife.get_branch_name ).to eq( 'giada/everyday_italian' )
      end
    end

    context 'with invalid knife.rb' do
      it 'system exists' do
        knife_rb = 'chef_serer_url "https://gordon.ramsay/organizations/hells_kitchen"'
        allow( ::File ).to receive( :read ).and_return( knife_rb )
        expect( @knife.ui ).to receive( :fatal ).with( "Invalid knife.rb at /path/to/chef/files/knife.rb")
        expect{ @knife.get_branch_name }.to raise_error( SystemExit )
      end
    end
  end

  describe 'SwitchAdd.checkout' do
    before :each do
      @branch = double( 'Git::Branch' )
      allow( @git ).to receive( :branch ).and_return( @branch )
    end

    it 'checks out the branch' do
      expect( @branch ).to receive( :checkout )
      @knife.checkout( 'BRANCH' )
    end

    it 'system exits on error' do
      error = Git::GitExecuteError.new( 'unable to checkout branch' )
      expect( @branch ).to receive( :checkout ).and_raise( error )
      expect( @knife.ui ).to receive( :fatal ).with( 'unable to checkout branch' )
      expect{ @knife.checkout( 'BRANCH' ) }.to raise_error( SystemExit )
    end
  end

  describe 'SwitchAdd.copy_files' do
    before :each do
      allow( @knife ).to receive( :dot_chef_path ).and_return( '/dot/chef' )
    end

    it 'copies files into dot chef folder' do
      expect( ::FileUtils ).to receive( :copy ).with( '/path/to/chef/files/knife.rb', '/dot/chef/knife.rb' )
      expect( ::FileUtils ).to receive( :copy ).with( '/path/to/chef/files/user.pem', '/dot/chef/user.pem' )
      expect( ::FileUtils ).to receive( :copy ).with( '/path/to/chef/files/org-validator.pem', '/dot/chef/org-validator.pem' )
      @knife.copy_files( mock_dot_chef_files )
    end
  end

  describe 'SwitchAdd.clean_files' do
    before :each do
      allow( ::Dir ).to receive( :glob ).and_return( mock_dot_chef_files )
      allow( ::File ).to receive( :file? ).and_return( true )
    end

    it 'deletes all the files' do
      expect( ::File ).to receive( :unlink ).with( '/path/to/chef/files/knife.rb' )
      expect( ::File ).to receive( :unlink ).with( '/path/to/chef/files/user.pem' )
      expect( ::File ).to receive( :unlink ).with( '/path/to/chef/files/org-validator.pem' )
      @knife.clean_files
    end
  end

  describe 'SwitchAdd.commit' do
    before :each do
      allow( @git ).to receive( :add )
      allow( @knife ).to receive( :kit_path ).and_return( mock_dot_chef )
    end

    it 'commits with correct message' do
      expect( @git ).to receive( :commit ).with( 'Adding BRANCH from /path/to/chef/files' )
      @knife.commit( 'BRANCH' )
    end

    it 'system exits on error' do
      error = Git::GitExecuteError.new( 'unable to commit branch' )
      expect( @git ).to receive( :commit ).and_raise( error )
      expect( @knife.ui ).to receive( :fatal ).with( 'unable to commit branch' )
      expect{ @knife.commit( 'BRANCH' ) }.to raise_error( SystemExit )
    end
  end

  describe 'SwitchAdd::branch_exists?' do

    let :branches do
      branches = []
      5.times do |n|
        branch = double( 'Git::Branch')
        branch.define_singleton_method(:name) { "branch#{n}" }
        branches << branch
      end
      branches
    end

    before :each do
      @branches = branches
      allow( @git ).to receive( :branches ).and_return( @branches )
      allow( @branches ).to receive( :local ).and_return( @branches )
    end

    it 'returns !nil if branch exists' do
      expect( @knife.branch_exists? 'branch1' ).not_to be(nil)
    end

    it 'returns nil if branch does not exists' do
      expect( @knife.branch_exists? 'unknown' ).to be(nil)
    end
  end
end
