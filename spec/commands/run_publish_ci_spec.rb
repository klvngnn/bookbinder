require 'spec_helper'

describe Cli::RunPublishCI do
  let(:fake_publish) { double }
  let(:fake_push_local_to_staging) { double }
  let(:fake_build_and_push_tarball) { double }
  let(:config_hash) { {'book_repo' => 'foo/bar'} }
  let(:config) { Configuration.new(config_hash) }
  let(:command) { Cli::RunPublishCI.new(config) }

  before do
    Cli::Publish.stub(:new) { fake_publish }
    Cli::PushLocalToStaging.stub(:new) { fake_push_local_to_staging }
    Cli::BuildAndPushTarball.stub(:new) { fake_build_and_push_tarball }
  end

  context 'when ENV["BUILD_NUMBER"] is set' do
    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('BUILD_NUMBER').and_return('42424242')
    end

    it 'runs three commands and returns 0 if all three do so' do
      fake_publish.should_receive(:run).with(['github']).and_return(0)
      fake_push_local_to_staging.should_receive(:run).with([]).and_return(0)
      fake_build_and_push_tarball.should_receive(:run).with([]).and_return(0)
      result = command.run []
      expect(result).to eq(0)
    end

    it 'does not execute PushLocalToStaging if Publish fails' do
      fake_publish.should_receive(:run).with(['github']).and_return(1)
      fake_push_local_to_staging.should_not_receive(:run)
      fake_build_and_push_tarball.should_not_receive(:run)
      result = command.run []
      expect(result).to eq(1)
    end

    it 'does not execute BuildAndPushTarball if PushLocalToStaging fails' do
      fake_publish.should_receive(:run).with(['github']).and_return(0)
      fake_push_local_to_staging.should_receive(:run).with([]).and_return(1)
      fake_build_and_push_tarball.should_not_receive(:run)
      result = command.run []
      expect(result).to eq(1)
    end
  end

  it 'raises MissingBuildNumber if ENV["BUILD_NUMBER"] is not set' do
    expect {
      command.run([])
    }.to raise_error(Cli::BuildAndPushTarball::MissingBuildNumber)
  end
end