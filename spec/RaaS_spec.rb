require 'spec_helper'

describe "RaaS" do
  let(:options) do
    {
      url: "http://www.google.co.jp",
      endpoint_url: "http://localhost:5002"
    }
  end

  describe ".get" do
    it "calls .execute with the :get method and given options" do
      RaaS.should_receive(:execute).with(:get, options)
      RaaS.get(options)
    end
  end

  describe ".post" do
    it "calls .execute with the :post method and given options" do
      RaaS.should_receive(:execute).with(:post, options)
      RaaS.post(options)
    end
  end

  describe ".execute" do
    context "with invalid options" do
      it "raises a RaaS::InvalidUrl error if the URL is not present" do
        expect { RaaS.execute(:get, {}) }.to raise_error(RaaS::InvalidUrl)
        expect { RaaS.execute(:get, {url: "  "}) }.to raise_error(RaaS::InvalidUrl)
      end

      it "raises a RaaS::InvalidUrl error if the URL has an unsupported scheme" do
        expect { RaaS.execute(:get, {url: "ftp://example.com"}) }.to raise_error(RaaS::InvalidUrl)
      end

      it "raises a RaaS::InvalidEndpointUrl error if the endpoint is not present" do
        expect { RaaS.execute(:get, {url: "http://example.com"}) }.to raise_error(RaaS::InvalidEndpointUrl)
      end
    end

    context "with valid options" do
      it "does not raise an error" do
        expect { RaaS.execute(:get, options) }.not_to raise_error
      end
    end
  end
end
