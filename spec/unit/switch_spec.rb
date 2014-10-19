require File.expand_path( '../../spec_helper', __FILE__ )

describe KnifeOrgUtils::Switch do

  let( :branch ) do
    'NEW/BRANCH'
  end

  before :each do
    @knife = KnifeOrgUtils::Switch.new
    @git = double( 'Git' )
    allow( ::Git ).to receive( :open ).with( '~/.chef' ).and_return( @git )
  end

  context 'if branch not provided' do
    it 'prints usage' do
      expect( @knife.ui ).to receive( :fatal ).with( "You must specify an BRANCH name" )
      expect( @knife ).to receive( :show_usage )
      expect{ @knife.run }.to raise_error( SystemExit )
    end
  end

  context 'if branch is provided' do
    before :each do
      @knife.name_args << branch
    end

    it 'checks out the specified branch' do
      expect( @git ).to receive( :checkout ).with( branch )
      expect( @knife.ui ).to receive( :msg ).with( "Switched to branch #{branch}" )
      @knife.run
    end

    it 'errors out if the branch is not available' do
      error = Git::GitExecuteError.new( 'branch does not exist' )
      allow( @git ).to receive( :checkout ).and_raise( error )
      expect( @knife.ui ).to receive( :error ).with( 'branch does not exist' )
      @knife.run
    end
  end
end
