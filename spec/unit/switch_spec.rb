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

  let(:branches) do
    ['prod/org1', 'prod/org2']
  end

  context 'correct option passed' do
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
          :type => 'M'
      }
    end

    before :each do
      @status = double('status')
      @status_file = Git::Status::StatusFile.new(@git,hash)
      @changed_files = {
          'file.rb' => @status_file
      }
      @added_files = {}
      @deleted_files = {}
      allow(@git).to receive(:status).and_return(@status)
      allow(@git.status).to receive(:changed).and_return(@changed_files)
      allow(@git.status).to receive(:added).and_return(@added_files)
      allow(@git.status).to receive(:deleted).and_return(@deleted_files)
    end

    it 'prints the status' do
      @knife.config[:status] = true
      expect(@knife).to receive(:puts).with('File file.rb has changed')
      @knife.run
    end

    it 'commits changes' do
      @knife.config[:commit] = true
      allow(@git).to receive(:add).with(:all=>true)
      expect(@git).to receive(:commit).with('Committing changes to files ["file.rb"]')
      @knife.run
    end
  end
end
