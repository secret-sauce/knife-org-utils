require File.expand_path('../../spec_helper', __FILE__)

describe KnifeOrgUtils::Info do

  let(:username) do
    'user'
  end

  let(:host) do
    'test'
  end

  let(:domain) do
    'chef.org'
  end

  let(:organization) do
    'org'
  end

  let(:url) do
    "https://#{host}.#{domain}/organizations/#{organization}"
  end

  let(:config_file) do
    "/home/#{username}/.chef/knife.rb"
  end

  before :each do
    @knife = Chef::Knife::KnifeOrgUtils::Info.new
    Chef::Knife.stub(:locate_config_file).and_return(config_file)
    @knife.stub(:server_url).and_return(url)
    @knife.stub(:username).and_return(username)
  end

  context 'if env user DOES NOT match' do
    before :each do
      ENV['USER'] = 'none'
    end

    it 'and tiny=true should print concise info in oneline' do
      @knife.config[:tiny] = true
      @knife.ui.should_receive(:msg).with("#{username}@#{host}/#{organization}")
      @knife.run
    end

    it 'and medium=true should print info in oneline' do
      @knife.config[:medium] = true
      @knife.ui.should_receive(:msg).with("#{username}@#{host}.#{domain}/#{organization}")
      @knife.run
    end
  end

  context 'if env user match' do
    before :each do
      ENV['USER'] = username
    end

    it 'and tiny=true should print concise info without username' do
      @knife.config[:tiny] = true
      @knife.ui.should_receive(:msg).with("#{host}/#{organization}")
      @knife.run
    end

    it 'and medium=true should print concise info without username' do
      @knife.config[:medium] = true
      @knife.ui.should_receive(:msg).with("#{host}.#{domain}/#{organization}")
      @knife.run
    end
  end

  it 'if long=true should print info in multi-line' do
    @knife.config[:long] = true
    expected = [
        "Host: #{host}.#{domain}",
        "Username: #{username}",
        "Organization: #{organization}",
        "Config File: #{config_file}",
        ""
    ]
    @knife.ui.should_receive(:msg).with(expected.join("\n"))
    @knife.run
  end

  context 'if config file is not found' do
    before :each do
      Chef::Knife.stub(:locate_config_file).and_return(nil)
    end

    it 'should print nothing' do
      @knife.ui.should_receive(:msg).exactly(0).times
      @knife.run
    end
  end
end
