require File.expand_path('../../spec_helper', __FILE__)

describe KnifeSwitch::Switch do

  before :each do
    @knife = Chef::Knife::Switch.new
    @git = double('git')
    allow(::Git).to receive(:open).with('~/.chef').and_return(@git)
    allow(@git).to receive(:status)
  end

  context 'incorrect option names/values' do
    it 'prints the right message when no options are passed' do
      @knife.config[:branch] = nil
      expect(@knife).to receive(:show_usage)
      @knife.run
    end

    it 'prints the right message when an invalid option is passed' do
      @knife.config[:random] = 'branch_name'
      expect(@knife).to receive(:show_usage)
      @knife.run
    end
    
    it 'prints an error msg when the branch does not exist' do
      @knife.config[:branch] = 'non-branch'
      error = Git::GitExecuteError.new('This branch does not exist')
      allow(@git).to receive(:checkout).and_raise(error)
      expect(@knife).to receive(:puts).with('This branch does not exist')
      @knife.run
    end
  end

  context 'correct option passed' do
    let(:branches) do
      ['prod/org1', 'prod/org2']
    end
    
    it 'prints the right message' do
      @knife.config[:branch] = 'prod/org1'
      allow(@git).to receive(:checkout).with('prod/org1')
      expect(@knife).to receive(:puts).with('Switched to branch prod/org1')
      @knife.run
    end

    it 'prints the list of branches' do
      @knife.config[:list] = true
      allow(@git).to receive(:branches).and_return(branches)
      allow(@knife).to receive(:puts).with('Available Branches: ')
      expect(@knife).to receive(:puts).with('["prod/org1", "prod/org2"]')  
      @knife.run  
    end
  end

  context 'committing changes' do
    let(:hash) do
      {
        :path => "file.rb",
        :type => "changed"
      }
    end

    it 'prints the status' do
      @knife.config[:status] = true
      file = Git::Status::StatusFile.new('./',hash)
      status = Git::Status.new('./file.rb')
      # allow(status).to receive(:changed).and_return('file1')
      allow(@git).to receive(:status).and_return(status)
      expect(@knife).to receive(:puts).with('File file1 has changed')
      @knife.run
    end

    it 'prints the list of branches' do
      @knife.config[:list] = true
      allow(@git).to receive(:branches).and_return(branches)
      allow(@knife).to receive(:puts).with('Available Branches: ')
      expect(@knife).to receive(:puts).with('["prod/org1", "prod/org2"]')  
      @knife.run  
    end
  end
end
