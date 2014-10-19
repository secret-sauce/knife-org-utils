require File.expand_path('../../spec_helper', __FILE__)

describe KnifeOrgUtils::SwitchList do

  let ( :local_branches ) do
    %w(
      server1/org1
      server1/org2
      server2/org1
      server2/org2
      server2/org3
      server3/org1
    )
  end

  before :each do
    @knife = KnifeOrgUtils::SwitchList.new
    @git = double( 'Git' )
    @branches = double( 'Git::Branches' )
    allow( ::Git ).to receive( :open ).with( '~/.chef' ).and_return( @git )
    allow( @git ).to receive( :branches ).and_return( @branches )
    allow( @branches ).to receive( :local ).and_return( local_branches )
  end

  it 'lists all local branches' do
    expect( @knife.ui ).to receive( :msg ).with( local_branches )
    @knife.run
  end

end
