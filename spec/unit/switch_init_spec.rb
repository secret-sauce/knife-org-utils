require File.expand_path( '../../spec_helper', __FILE__ )

describe KnifeOrgUtils::SwitchInit do

  let( :dot_chef_path ) do
    '/path/to/.chef'
  end

  before :each do
    @knife = KnifeOrgUtils::SwitchInit.new
    allow( @knife ).to receive( :dot_chef_path ).and_return( dot_chef_path )
  end

  context 'if .chef folder exists' do
    it 'exit with error' do
      allow( ::File ).to receive( :directory? ).with( dot_chef_path ).and_return( true )
      expect( @knife.ui ).to receive( :error ).with( "Directory #{dot_chef_path} exists. Please backup and remove this directory before initializing." )
      expect{ @knife.run }.to raise_error( SystemExit )
    end
  end

  context 'if .chef folder does not exist' do
    it 'creates .chef folder' do
      allow( ::File ).to receive( :directory? ).with( dot_chef_path ).and_return( false )
      expect( ::Dir ).to receive( :mkdir ).with( dot_chef_path )
      @knife.run
    end
  end
end
