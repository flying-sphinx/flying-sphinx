require 'spec_helper'

describe 'Requesting customer information' do
  let(:configuration) { FlyingSphinx::Configuration.new 'foo', 'bar' }

  before :each do
    stub_digest_request(:get, 'https://flying-sphinx.com/api/my/app/v5').
      to_return(
        :status => 200,
        :body   => '{"server":"my.sphinx.server","port":9307}'
      )
  end

  it { expect(configuration.host).to eq('my.sphinx.server') }
  it { expect(configuration.port).to eq(9307) }
end
